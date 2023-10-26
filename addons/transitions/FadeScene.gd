extends CanvasLayer

signal fade_done

@export var fade_time_seconds:float

# $Sprite is added dynamically from within the Transitions.gd code; this way,
# we don't need to explicitly have a .tscn file for this scene.

var _total_time:float = 0
var _enabled = false

func start():
	_enabled = true

func _process(delta:float):
	if not _enabled:
		return
		
	if _total_time >= fade_time_seconds:
		emit_signal("fade_done")
		queue_free()
		
	_total_time += delta
	var fade_amount = _total_time / fade_time_seconds
	$Sprite2D.material.set_shader_parameter("dissolve_amount", fade_amount)
