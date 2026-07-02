extends Node2D

# Referencia a la escena de presentación
@onready var presentacion = $PresentacionNivel

# Referencia a la música de fondo
@onready var musica_fondo = $AudioStreamPlayer 

func _ready() -> void:
	# 1. Conectamos la señal para que el nivel sepa cuándo termina el video
	presentacion.presentacion_terminada.connect(_on_presentacion_terminada)
	
	# 2. Le damos Play a la presentación
	presentacion.iniciar()

# --- FUNCIÓN QUE SE EJECUTA AL TERMINAR LA ESTÁTICA ---
func _on_presentacion_terminada() -> void:
	print("¡La presentación terminó! El nivel está listo.")
	
	# 3. ¡Arrancamos la música de fondo ahora que no hay estática!
	musica_fondo.play()
