extends Node2D

# Referencia a la escena de presentación
@onready var presentacion = $PresentacionNivel

func _ready() -> void:
	# 1. Conectamos la señal para que el nivel sepa cuándo termina el video
	presentacion.presentacion_terminada.connect(_on_presentacion_terminada)
	
	# 2. Le damos Play a la presentación
	presentacion.iniciar()

# --- FUNCIÓN QUE SE EJECUTA AL TERMINAR LA ESTÁTICA ---
func _on_presentacion_terminada() -> void:
	# Aquí el nivel ya sabe que la pantalla está libre. 
	# Puedes dejarlo vacío o poner un print para comprobar que funciona.
	print("¡La presentación terminó! El nivel está listo.")
