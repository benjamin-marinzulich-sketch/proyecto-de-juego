extends Node2D

# --- VARIABLES DEL CONTEO ---
@onready var label_conteo = $CanvasLayer/LabelConteo
var tiempo_restante = 3

# --- VARIABLES DE LOS CARTELES (TUTORIAL) ---
@onready var cartel_movimiento = $CartelMovimiento
@onready var cartel_ataque = $CartelAtaque

func _ready() -> void:
	# 0. Ocultamos el cartel de ataque desde el principio
	if cartel_ataque:
		cartel_ataque.modulate.a = 0.0

	# 1. Voltear los personajes para que se miren de frente al iniciar
	if has_node("LuxoJr"):
		get_node("LuxoJr/AnimatedSprite2D").flip_h = true 
		
	if has_node("CharacterBody2D"):
		get_node("CharacterBody2D/AnimatedSprite2D").flip_h = true 

	# 2. Congelamos a tus personajes para el conteo
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
	
	# Escondemos el texto del conteo
	label_conteo.visible = false
	
	# 4. ¡A PELEAR! Devolvemos las físicas a tus personajes
	if has_node("LuxoJr"):
		get_node("LuxoJr").set_physics_process(true)
	if has_node("CharacterBody2D"):
		get_node("CharacterBody2D").set_physics_process(true)
		
	# 5. Iniciamos la secuencia de los carteles ahora que ya pueden moverse
	_secuencia_carteles()

# --- NUEVA FUNCIÓN: SECUENCIA DEL TUTORIAL ---
func _secuencia_carteles() -> void:
	# Por seguridad, verificamos que los carteles existan en la escena
	if not cartel_movimiento or not cartel_ataque:
		return
		
	# 1. Dejamos que el jugador lea el de movimiento por 5 segundos
	await get_tree().create_timer(3.0).timeout
	
	# 2. Desaparecemos el cartel de movimiento suavemente
	var tween_mov = create_tween()
	tween_mov.tween_property(cartel_movimiento, "modulate:a", 0.0, 1.0)
	await tween_mov.finished
	cartel_movimiento.queue_free() 
	
	# 3. Hacemos aparecer el cartel de ataque
	var tween_ataque_in = create_tween()
	tween_ataque_in.tween_property(cartel_ataque, "modulate:a", 1.0, 1.0)
	await tween_ataque_in.finished
	
	# 4. Lo dejamos visible en pantalla por otros 5 segundos
	await get_tree().create_timer(3.0).timeout
	
	# 5. Finalmente, desaparecemos el cartel de ataque
	var tween_ataque_out = create_tween()
	tween_ataque_out.tween_property(cartel_ataque, "modulate:a", 0.0, 1.0)
	await tween_ataque_out.finished
	cartel_ataque.queue_free()
