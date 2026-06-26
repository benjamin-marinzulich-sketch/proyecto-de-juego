extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pausa"):
		alternar_pausa()

func alternar_pausa() -> void:
	get_tree().paused = not get_tree().paused
	visible = get_tree().paused

func _on_boton_continuar_pressed() -> void:
	if get_tree().paused:
		alternar_pausa()

func _on_boton_salir_pressed() -> void:
	get_tree().paused = false
	hide()
	get_tree().change_scene_to_file("res://scenas/ui/selector/SelectorNiveles.tscn")
