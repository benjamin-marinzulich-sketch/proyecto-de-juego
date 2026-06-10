extends CanvasLayer

func _ready():
	# Asegurarnos de que el menú empiece oculto al iniciar el juego
	hide()

func _input(event):
	# Detectamos si se presiona la tecla que configuramos
	if event.is_action_pressed("pausa"):
		alternar_pausa()

func alternar_pausa():
	# Invertimos el estado de pausa actual (si está pausado lo despausa, y viceversa)
	get_tree().paused = not get_tree().paused
	
	# Mostramos u ocultamos el menú visualmente
	if get_tree().paused:
		show()
	else:
		hide()

# --- Conexión de Señales ---

func _on_boton_continuar_pressed():
	alternar_pausa()

func _on_boton_salir_pressed():
	# Cierra el juego por completo
	get_tree().quit()
