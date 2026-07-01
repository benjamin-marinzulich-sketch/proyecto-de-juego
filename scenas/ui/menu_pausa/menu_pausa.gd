extends CanvasLayer

func _ready():
	# Nos aseguramos de que el menú responda siempre, incluso en pausa
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func _unhandled_input(event):
	# Detecta directamente la tecla Escape física (ESC) al ser presionada
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_ESCAPE:
			alternar_pausa()

func alternar_pausa():
	# Invierte el estado de pausa del juego
	get_tree().paused = not get_tree().paused
	
	# Muestra u oculta el menú
	if get_tree().paused:
		show()
	else:
		hide()

# --- Conexión de Señales ---

func _on_boton_continuar_pressed():
	# Volvemos a lo que tenías antes: el botón ejecuta la misma lógica
	alternar_pausa()

func _on_boton_salir_pressed():
	get_tree().quit()

func _on_boton_opciones_pressed() -> void:
	# Corregido a .instantiate() para que no te dé error en Godot 4
	var opciones = load("res://scenes/ui/opciones/OpcionesScene.tscn").instantiate()
	get_tree().root.add_child(opciones)
