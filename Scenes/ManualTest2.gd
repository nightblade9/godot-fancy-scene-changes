extends Node2D

var ManualTest1 = load('res://Scenes/ManualTest1.tscn')
const DISSOLVE_IMAGE = preload("res://addons/transitions/images/blurry-noise.png")

func _unhandled_key_input(event):
	if event.pressed:
		Transitions.change_scene(ManualTest1.instance(), Transitions.FadeType.Blend, 1, DISSOLVE_IMAGE)
