extends HBoxContainer

@onready var heart1 = $Heart1
@onready var heart2 = $Heart2
@onready var heart3 = $Heart3

var heartbeat_tween : Tween

func _ready():
	# Buscamos al personaje (ajusta la ruta según tu escena si es necesario)
	var personaje = get_tree().get_first_node_in_group("res://scenas/TOM/character_body_2d.tscn") 
	
	if personaje:
		# Conectamos la señal del personaje a nuestra función
		personaje.vida_cambiada.connect(_on_personaje_vida_cambiada)
		# Actualizamos la vida inicial de Tom
		actualizar_corazones(personaje.vida)
	else:
		print("¡Error! No encuentro al personaje desde la barra de vida.")

# Esta función se ejecutará automáticamente cuando Tom reciba daño
func _on_personaje_vida_cambiada(nueva_vida: int):
	actualizar_corazones(nueva_vida)

func actualizar_corazones(vida_actual: int):
	heart1.visible = vida_actual >= 1
	heart2.visible = vida_actual >= 2
	heart3.visible = vida_actual >= 3

	if vida_actual == 1:
		iniciar_latido(heart1)
	else:
		detener_latido(heart1)

func iniciar_latido(corazon: TextureRect):
	if heartbeat_tween and heartbeat_tween.is_valid():
		return 
		
	heartbeat_tween = create_tween().set_loops()
	heartbeat_tween.tween_property(corazon, "scale", Vector2(1.3, 1.3), 0.15).set_trans(Tween.TRANS_SINE)
	heartbeat_tween.tween_property(corazon, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_SINE)
	heartbeat_tween.tween_interval(0.3)

func detener_latido(corazon: TextureRect):
	if heartbeat_tween:
		heartbeat_tween.kill() 
	corazon.scale = Vector2(1.0, 1.0)
