extends Node2D

# Vinculamos el texto del conteo (está perfecto en tu CanvasLayer)
@onready var label_conteo = $CanvasLayer/LabelConteo

var tiempo_restante = 3

func _ready() -> void:
	# 1. Voltear los personajes para que se miren de frente al iniciar
	# Suponiendo que LuxoJr (Tom) empieza a la derecha y debe mirar a la izquierda:
	if has_node("LuxoJr"):
		# Buscamos su AnimatedSprite2D. Cambia "AnimatedSprite2D" por su nombre exacto si es otro.
		get_node("LuxoJr/AnimatedSprite2D").flip_h = true 
		
	# Suponiendo que el Boss (CharacterBody2D) empieza a la izquierda y debe mirar a la derecha:
	if has_node("CharacterBody2D"):
		# Falso significa que se queda con su orientación original (mirando a la derecha)
		get_node("CharacterBody2D/AnimatedSprite2D").flip_h = true 

	# 2. Congelamos a tus personajes para el conteo (Esto ya lo tenían)
	if has_node("LuxoJr"):
		get_node("LuxoJr").set_physics_process(false)
	if has_node("CharacterBody2D"): 
		get_node("CharacterBody2D").set_physics_process(false)
		
	# 3. Mostramos el "3" inicial y arrancamos
	label_conteo.text = str(tiempo_restante)
	_iniciar_cuenta_regresiva()

func _iniciar_cuenta_regresiva() -> void:
	for i in range(3):
		await get_tree().create_timer(1.0).timeout
		tiempo_restante -= 1
		
		if tiempo_restante > 0:
			label_conteo.text = str(tiempo_restante)
	
	# Mensaje de inicio
	label_conteo.text = "¡READY!"
	await get_tree().create_timer(0.8).timeout
	
	# Escondemos el texto
	label_conteo.visible = false
	
	# 4. ¡A PELEAR! Devolvemos las físicas a tus personajes reales
	if has_node("LuxoJr"):
		get_node("LuxoJr").set_physics_process(true)
	if has_node("CharacterBody2D"):
		get_node("CharacterBody2D").set_physics_process(true)
