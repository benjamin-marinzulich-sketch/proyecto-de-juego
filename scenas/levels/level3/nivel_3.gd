extends Node2D

@onready var presentacion = $PresentacionNivel
@onready var musica_fondo = $AudioStreamPlayer

func _ready() -> void:
	presentacion.presentacion_terminada.connect(_on_presentacion_terminada)


	get_tree().paused = true

	presentacion.iniciar()

func _on_presentacion_terminada() -> void:
	print("¡La presentación terminó! El nivel está listo.")

	get_tree().paused = false

	musica_fondo.play()
