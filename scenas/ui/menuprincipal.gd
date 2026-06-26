extends Control

func _on_texture_button_pressed() -> void:
	AudioManager.play_ui_select()
	get_tree().change_scene_to_file("res://scenas/ui/selector/SelectorNiveles.tscn")
