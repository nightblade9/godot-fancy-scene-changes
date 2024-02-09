@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton('Transitions', 'Transitions.gd')
	add_autoload_singleton('FancyFade', 'FancyFade.gd')

func _exit_tree():
	remove_autoload_singleton('Transitions')
	remove_autoload_singleton('FancyFade')
