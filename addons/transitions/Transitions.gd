extends CanvasLayer

signal pre_transition

const FadeScene = preload("res://addons/transitions/FadeScene.gd")

var _root:Viewport
var scene_container:Node setget _set_scene_container

enum FadeType {
	Instant, # immediately change
	CrossFade, # naively fade in the new scene
	Blend # alpha blend one into the other using a texture to control the fade
}

func _set_scene_container(new_container:Node):
	# Allow users to specify their own scene container node.
	if new_container == null:
		push_error("Can't change scene container to null scene!")
	scene_container = new_container

func _get_current_scene():
	
	var num_nodes =  scene_container.get_child_count()
	
	for i in range(num_nodes):
		var candidate = scene_container.get_child(num_nodes - i - 1)
		if not candidate is FadeScene and not candidate is Tween and not candidate is Timer:
			return candidate
	
	push_error("Couldn't ascertain current scene")
	return null
			
func _ready():
	_root = get_tree().root
	# Set the default container to be the root viewport.
	# This maintains backwards compatability with previous versions.
	scene_container = _root

func change_scene(new_scene, fade_type, fade_time_seconds:float = 1.0, shader_image:StreamTexture = null) -> void:
	if new_scene == null:
		push_error("Can't change scene to null scene!")
	elif not is_instance_valid(new_scene):
		push_error("Can't change to scene that's freed!")
	
	if fade_type == FadeType.Blend and shader_image == null:
		push_error("You need to specify a shader image for blending!")
	
	var data = _common_pre_fade(fade_type, fade_time_seconds, shader_image)
	_set_scene(new_scene)
	emit_signal("pre_transition")
	
	var coroutine = _common_wait_for_fade(data, fade_type, fade_time_seconds)
	yield(coroutine, "completed")
	
	_common_post_fade(data, new_scene)
	
func _common_pre_fade(fade_type, fade_time_seconds:float, shader_image:StreamTexture = null) -> Array:
	# NB: Remember spending 8 hours fruitlessly fixing that extra frame in dissolve
	# fades? The one that's shrank to 1x zoom and (0, 0) on the map?
	# Turns out it was a yield here for delay_before_fade_seconds. Whether you
	# specify a zero or non-zero value, it will introduce that extra frame. Sad.
	
	####### NOTE: might be solvable with yield(get_tree(), "idle_frame")
	# Take a screenshot of the old scene. This is the only reliable way to make
	# complex transitions. Cross-scene fades doesn't work well with multiple cameras;
	# somehow, they just end up with extra frames randomly blitting mid-way.
	var screenshot:Sprite = _take_screenshot()
	# Don't need the sprite mate, just the texture, for our "fade scene" that has
	# a CanvasLayer root and a sprite with the material/shader/params preset (no
	# easy way to set a shader in GDscript)
	var fade_scene = _create_fade_scene(shader_image)
	fade_scene.fade_time_seconds = fade_time_seconds

	var sprite = fade_scene.get_node("Sprite")
	sprite.texture = screenshot.texture
	
	# If the Godot project has test_width and test-height,  the screenshot will 
	# be the window size, not the game size, so it won't perfectly match; actual
	# game will look fine, though. To fix this, scale as needed.
	# eg. if the game is 960x540 but test_width/test_height is 1600x900, the
	# screenshot is 1600x900; so it looks zoomed in :facepalm:
	var game_width:float = ProjectSettings.get_setting("display/window/size/width")
	var game_height:float = ProjectSettings.get_setting("display/window/size/height")
	var screenshot_width:float = screenshot.texture.get_width()
	var screenshot_height:float = screenshot.texture.get_height()
	
	# correction for changed aspect ratio
        
	var default_aspect_ratio:float = game_width / game_height
	var new_aspect_ratio:float = screenshot_width / screenshot_height
	var fixed_game_width:float
	var fixed_game_height:float
	
	if(new_aspect_ratio > default_aspect_ratio): # it is wider
			fixed_game_width = game_width * new_aspect_ratio / default_aspect_ratio
			fixed_game_height = game_height
	elif((new_aspect_ratio < default_aspect_ratio)): # it is higher
			fixed_game_width = game_width
			fixed_game_height = game_height * (screenshot_height/screenshot_width) / (game_height / game_width)
	else: # aspect ratio didn't change
			fixed_game_width = game_width
			fixed_game_height = game_height
	
	var sprite_scale = Vector2(fixed_game_width / screenshot_width, fixed_game_height / screenshot_height)
	sprite.scale = sprite_scale
	_root.call_deferred("add_child", fade_scene)
	
	# Remove visual abberations for other fades
	if fade_type != FadeType.Blend:
		sprite.material = null
	
	# Needed because changing texture on one instance seems to change all of them
	if fade_type == FadeType.Blend:
		sprite.material.set_shader_param("dissolve_texture", shader_image)
	
	return [_root, fade_scene, sprite]

func _common_wait_for_fade(data:Array, fade_type, fade_seconds:float) -> void:
	var fade_scene = data[1]
	var sprite = data[2]
	
	# This function doesn't return, but yields. Since it's not called directly
	# as a root function of this script, but called from another method, we need
	# to call yield(coroutine, "completed") on the results of this (yield) below.
	
	# Creating a 0s timer no longer works here, so we tween for 0s instead.
	if fade_type == FadeType.Instant:
		fade_seconds = 0.0
	
	if fade_type == FadeType.CrossFade or fade_type == FadeType.Instant:
		var tween = Tween.new()
		_root.call_deferred("add_child", tween)
		yield(tween, "ready")
		tween.interpolate_property(sprite, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), fade_seconds)
		tween.start()
		yield(tween, "tween_completed")
	elif fade_type == FadeType.Blend:
		# wait for shader fade to complete
		fade_scene.start()
		yield(fade_scene, "fade_done")
		
	else:
		push_error("Missing implementation in _common_wait_for_fade for fade-type %s" % fade_type)

# new_scene is either Node2D or PackedScene. #herp #derp
func _common_post_fade(data:Array, new_scene) -> void:
	var fade_scene = data[1]
	if fade_scene in _root:
		_root.remove_child(fade_scene)

func _set_scene(new_scene:Node):
	# Dispose old scene so we don't get any camera jitters or wierdness.
	var previous_scene = _get_current_scene()
	
	scene_container.remove_child(previous_scene)
	print("killed previous scene %s" % previous_scene)
	previous_scene.queue_free()
	
	scene_container.add_child(new_scene)
	get_tree().current_scene = new_scene

# Necessary for those buttery-smooth jitter-free fades
func _take_screenshot():
	var image:Image = _root.get_texture().get_data()
	# Flip it on the y-axis (because it's flipped)
	image.flip_y()
	
	var image_texture = ImageTexture.new()
	image_texture.create_from_image(image)
	image_texture.flags = 0 # turn off "Filter" so it's pixel perfect

	var sprite = Sprite.new()
	sprite.texture = image_texture
	sprite.centered = false
	
	return sprite

func _create_fade_scene(texture:StreamTexture) -> Node:
	var canvas = CanvasLayer.new()
	canvas.set_script(load("res://addons/transitions/FadeScene.gd"))
	
	var sprite = Sprite.new()
	sprite.centered = false
	sprite.name = "Sprite"
	canvas.add_child(sprite)
	
	var shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://addons/transitions/Dissolve2d.shader")
	shader_material.set_shader_param("dissolve_texture", texture)
	sprite.material = shader_material
	
	return canvas
