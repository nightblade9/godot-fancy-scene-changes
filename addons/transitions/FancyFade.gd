extends Node

const _IMAGES = {
	# Wipes
	"wipe-left": preload("res://addons/transitions/images/wipe-left.png"),
	"wipe-right": preload("res://addons/transitions/images/wipe-right.png"),
	"wipe-up": preload("res://addons/transitions/images/wipe-up.png"),
	"wipe-down": preload("res://addons/transitions/images/wipe-down.png"),
	"conical": preload("res://addons/transitions/images/conical.png"),
	"square": preload("res://addons/transitions/images/square.png"),
	
	# Circles
	"circle-in": preload("res://addons/transitions/images/circle.png"),
	"circle-out": preload("res://addons/transitions/images/circle-inverted.png"),
	
	# Noises
	"noise": preload("res://addons/transitions/images/noise.png"),
	"blurry-noise": preload("res://addons/transitions/images/blurry-noise.png"),
	"noise-pixelated": preload("res://addons/transitions/images/noise-pixelated.png"),
	"cell-noise": preload("res://addons/transitions/images/cell-noise.png"),
	
	# Misc/artistic
	 "horizontal-paint-brush": preload("res://addons/transitions/images/horiz_paint_brush.png"),
	"vertical-paint-brush": preload("res://addons/transitions/images/vertical_paint_brush.png"),
	"swirl": preload("res://addons/transitions/images/swirl.png"),
	"tile_reveal": preload("res://addons/transitions/images/tile_reveal.png")
}

func instant_change(scene) -> void:
	Transitions.change_scene_to_instance(scene, Transitions.FadeType.Instant, 0)

func cross_fade(scene, fade_seconds:float = 1.0) -> void:
	Transitions.change_scene_to_instance(scene, Transitions.FadeType.CrossFade, fade_seconds)

func custom_fade(scene, fade_seconds:float = 1.0, shader_image:CompressedTexture2D = null) -> void:
	if shader_image == null:
		push_error("You must specify an image for custom fade! (Typically, use load(...))")

	Transitions.change_scene_to_instance(scene, Transitions.FadeType.Blend, fade_seconds, shader_image)

# Wipe/gradient
func wipe_left(scene, fade_seconds:float = 1.0) -> void:
	_fade("wipe-left", scene, fade_seconds)

func wipe_right(scene, fade_seconds:float = 1.0) -> void:
	_fade("wipe-right", scene, fade_seconds)

func wipe_up(scene, fade_seconds:float = 1.0) -> void:
	_fade("wipe-up", scene, fade_seconds)

func wipe_down(scene, fade_seconds:float = 1.0) -> void:
	_fade("wipe-down", scene, fade_seconds)

func wipe_square(scene, fade_seconds:float = 1.0) -> void:
	_fade("square", scene, fade_seconds)

func wipe_conical(scene, fade_seconds:float = 1.0) -> void:
	_fade("conical", scene, fade_seconds)

# Circle
func circle_in(scene, fade_seconds:float = 1.0) -> void:
	_fade("circle-in", scene, fade_seconds)

func circle_out(scene, fade_seconds:float = 1.0) -> void:
	_fade("circle-out", scene, fade_seconds)
	
# Noise
func noise(scene, fade_seconds:float = 1.0) -> void:
	_fade("noise", scene, fade_seconds)
	
func pixelated_noise(scene, fade_seconds:float = 1.0) -> void:
	_fade("noise-pixelated", scene, fade_seconds)
	
func blurry_noise(scene, fade_seconds:float = 1.0) -> void:
	_fade("blurry-noise", scene, fade_seconds)
	
func cell_noise(scene, fade_seconds:float = 1.0) -> void:
	_fade("cell-noise", scene, fade_seconds)

# Misc/artistic
func horizontal_paint_brush(scene, fade_seconds:float = 1.0) -> void:
	_fade("horizontal-paint-brush", scene, fade_seconds)

func vertical_paint_brush(scene, fade_seconds:float = 1.0) -> void:
	_fade("vertical-paint-brush", scene, fade_seconds)

func stripes_left(scene, fade_seconds:float = 1.0) -> void:
	_fade("stripes-left", scene, fade_seconds)

func stripes_right(scene, fade_seconds:float = 1.0) -> void:
	_fade("stripes-right", scene, fade_seconds)

func swirl(scene, fade_seconds:float = 1.0) -> void:
	_fade("swirl", scene, fade_seconds)

func tile_reveal(scene, fade_seconds:float = 1.0) -> void:
	_fade("tile_reveal", scene, fade_seconds)
	
# Core method
func _fade(type:String, scene, fade_seconds:float = 1.0) -> void:
	Transitions.change_scene_to_instance(scene, Transitions.FadeType.Blend, fade_seconds, _IMAGES[type])
