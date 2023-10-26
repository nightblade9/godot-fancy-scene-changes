extends Control

const DestinationScene = preload("res://Destination.tscn")

func _on_instant_button_pressed():
	Transitions.change_scene_to_file(DestinationScene.instantiate(), Transitions.FadeType.Instant)
	
func _on_cross_fade_button_pressed():
	pass # Replace with function body.


func _on_blend_button_pressed():
	pass # Replace with function body.
