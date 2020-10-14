extends CanvasLayer

const FadeScene = preload("res://addons/transitions/FadeScene.tscn")
var _current_scene = null

enum FadeType {
	Instant,
	CrossFade,
	Blend
}

func _ready():
	var root = get_tree().root
	_current_scene = root.get_child(root.get_child_count() - 1)

func change_scene(new_scene:Node2D, fade_type, fade_time_seconds:float, shader_image:StreamTexture = null) -> void:
	if new_scene == null:
		push_error("Can't change scene to null scene!")
	elif not is_instance_valid(new_scene):
		push_error("Can't change to scene that's freed!")
	
	if fade_type == FadeType.Blend and shader_image == null:
		push_error("You need to specify a shader image for shader cross-fades!")
	
	var data = _common_pre_fade(fade_type, fade_time_seconds, shader_image)
	_set_scene(new_scene)
	
	var coroutine = _common_wait_for_fade(data, fade_type, fade_time_seconds)
	yield(coroutine, "completed")
	
	_common_post_fade(data, new_scene)
	
func _common_pre_fade(fade_type, fade_time_seconds:float, shader_image:StreamTexture = null) -> Array:
	# NB: Remember spending 8 hours fruitlessly fixing that extra frame in dissolve
	# fades? The one that's shrank to 1x zoom and (0, 0) on the map?
	# Turns out it was a yield here for delay_before_fade_seconds. Whether you
	# specify a zero or non-zero value, it will introduce that extra frame. Sad.
	
	####### NOTE: might be solvable with yield(get_tree(), "idle_frame")
	var root = get_tree().root

	# Take a screenshot of the old scene. This is the only reliable way to make
	# complex transitions. Cross-scene fades doesn't work well with multiple cameras;
	# somehow, they just end up with extra frames randomly blitting mid-way.
	var screenshot:Sprite = _take_screenshot()
	# Don't need the sprite mate, just the texture, for our "fade scene" that has
	# a CanvasLayer root and a sprite with the material/shader/params preset (no
	# easy way to set a shader in GDscript)
	var fade_scene = FadeScene.instance()
	fade_scene.fade_time_seconds = fade_time_seconds

	var sprite = fade_scene.get_node("Sprite")
	sprite.texture = screenshot.texture
	root.add_child(fade_scene)
	
	# Remove visual abberations for other fades
	if fade_type != FadeType.Blend:
		sprite.material = null
	
	# Needed because changing texture on one instance seems to change all of them
	if fade_type == FadeType.Blend:
		sprite.material.set_shader_param("dissolve_texture", shader_image)
	
	return [root, fade_scene, sprite]

func _common_wait_for_fade(data:Array, fade_type, fade_seconds:float) -> void:
	var root = data[0]
	var fade_scene = data[1]
	var sprite = data[2]
	
	# This function doesn't return, but yields. Since it's not called directly
	# as a root function of this script, but called from another method, we need
	# to call yield(coroutine, "completed") on the results of this (yield) below.
	
	if fade_type == FadeType.CrossFade:
		var tween = Tween.new()
		root.add_child(tween)
		tween.interpolate_property(sprite, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), fade_seconds)
		tween.start()
		yield(tween, "tween_completed")
	elif fade_type == FadeType.Blend:
		# wait for shader fade to complete
		fade_scene.start()
		yield(fade_scene, "fade_done")
	else: # FadeType.instant
		# calling function expects something yieldable
		yield(get_tree().create_timer(0), "timeout")

# new_scene is either Node2D or PackedScene. #herp #derp
func _common_post_fade(data:Array, new_scene) -> void:
	var root = data[0]
	var fade_scene = data[1]
	
	root.remove_child(fade_scene)
	_current_scene = new_scene

func _set_scene(new_scene):
	# Dispose old scene so we don't get any camera jitters or wierdness.
	_current_scene.get_parent().remove_child(_current_scene)
	_current_scene.queue_free()
		
	var root = get_tree().root
	root.add_child(new_scene)

# Necessary for those buttery-smooth jitter-free fades
func _take_screenshot():
	var image:Image = get_tree().get_root().get_texture().get_data()
	# Flip it on the y-axis (because it's flipped)
	image.flip_y()
	
	var image_texture = ImageTexture.new()
	image_texture.create_from_image(image)
	image_texture.flags = 0 # turn off "Filter" so it's pixel perfect

	var sprite = Sprite.new()
	sprite.texture = image_texture
	sprite.centered = false
	
	return sprite

