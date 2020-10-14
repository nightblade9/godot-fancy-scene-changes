extends Node2D

var ManualTest1 = load('res://Scenes/ManualTest1.tscn')

func _unhandled_key_input(event):
	if event.pressed:
		Transitions.change_scene(ManualTest1.instance(), Transitions.FadeType.CrossFade, 1)
