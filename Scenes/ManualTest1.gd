extends Node2D

const ManualTest2 = preload('res://Scenes/ManualTest2.tscn')
const DISSOLVE_IMAGE = preload("res://addons/transitions/images/blurry-noise.png")

func _unhandled_key_input(event):
	if event.pressed:
		Transitions.change_scene(ManualTest2.instance(), Transitions.FadeType.Blend, 1, DISSOLVE_IMAGE)
