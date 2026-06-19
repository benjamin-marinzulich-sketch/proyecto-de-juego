extends Node

const HEART_SCENE = preload("res://scenas/ui/hud/HeartIcon.tscn")
@onready var contenedor = $ContenedorCorazones

# Buscamos al personaje en la escena padre
@onready var personaje = get_parent().get_node("CharacterBody2D")

func _ready():
	# Nos aseguramos de que el personaje exista antes de pedirle sus vidas
	if personaje:
		generar_corazones(personaje.vida) # Asegúrate de que tu personaje tenga una variable llamada 'vidas'
	else:
		print("¡Error! No encuentro al personaje.")

func generar_corazones(cantidad: int):
	for n in contenedor.get_children():
		n.queue_free()
	for i in range(cantidad):
		var nuevo_corazon = HEART_SCENE.instantiate()
		contenedor.add_child(nuevo_corazon)
