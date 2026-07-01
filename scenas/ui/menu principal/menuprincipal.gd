extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_texture_button_pressed() -> void:
	print("¡El botón ha sido presionado correctamente!")
	get_tree().change_scene_to_file("res://scenas/ui/selector/SelectorNiveles.tscn")


func _on_button_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://scenas/levels/Tutorial/Tutorial.tscn")
	pass # Replace with function body.
