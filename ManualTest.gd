extends Control

const DestinationScene = preload("res://Destination.tscn")
const FancyFade = preload("res://addons/transitions/FancyFade.gd")

func _on_instant_button_pressed():
	Transitions.change_scene_to_instance(DestinationScene.instantiate(), Transitions.FadeType.Instant)
	
func _on_cross_fade_button_pressed():
	Transitions.change_scene_to_instance(DestinationScene.instantiate(), Transitions.FadeType.CrossFade)

func _on_blend_button_pressed():
	FancyFade.new().blurry_noise(DestinationScene.instantiate())
