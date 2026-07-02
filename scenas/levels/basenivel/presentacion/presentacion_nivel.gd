extends CanvasLayer

signal presentacion_terminada 

@onready var animacion = $AnimacionConteo
@onready var audio_estatica = $AudioStreamPlayer

func _ready():
	hide()

func iniciar():
	show()
	animacion.play("conteo")
	audio_estatica.play()
	
	# CAMBIO AQUÍ: En vez de esperar a que termine la animación,
	# obligamos a Godot a esperar exactamente 2.0 segundos.
	await get_tree().create_timer(2.0).timeout
	
	hide()
	audio_estatica.stop()
	presentacion_terminada.emit()
