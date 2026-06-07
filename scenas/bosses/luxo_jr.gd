extends CharacterBody2D

const SPEED = 150.0 
const HOP_VELOCITY = -400.0 
const PAUSE_DURATION = 0.4 

var is_landing_paused = false 
var was_on_floor = true 
var direction = 1 

# --- NUEVAS VARIABLES DE SALUD DEL ENEMIGO ---
var vida = 5
var is_dead = false

@onready var _animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# 🪦 BLOQUEO TOTAL POR MUERTE: Si el enemigo murió, se apaga su lógica
	if is_dead:
		if not is_on_floor():
			velocity += get_gravity() * delta
		velocity.x = 0
		move_and_slide()
		return # Detiene por completo la IA de patrullaje y saltos

	# 1. Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Detector de impacto (Aterrizaje)
	if is_on_floor():
		if not was_on_floor:
			_trigger_landing_stomp()
		was_on_floor = true
	else:
		was_on_floor = false

	# 3. Bloqueo por pausa (Pisotón)
	if is_landing_paused:
		velocity.x = 0 
		_animated_sprite.play("hop_land")
		move_and_slide()
		return 

	# 4. Patrullaje automático
	if is_on_wall():
		direction *= -1

	velocity.x = direction * SPEED
	_animated_sprite.flip_h = direction > 0
	
	if is_on_floor():
		velocity.y = HOP_VELOCITY

	# 5. Control de animaciones
	if velocity.x != 0:
		if not is_on_floor():
			if velocity.y < -50:
				_animated_sprite.play("hop_up")
			else:
				_animated_sprite.play("hop_air")
		else:
			_animated_sprite.play("hop_up")
	else:
		_animated_sprite.play("idle")

	move_and_slide()

func _trigger_landing_stomp():
	is_landing_paused = true
	velocity = Vector2.ZERO 
	_animated_sprite.play("hop_land")
	await get_tree().create_timer(PAUSE_DURATION).timeout
	is_landing_paused = false


# --- DETECTOR DE CONTACTO PARA HACER DAÑO A TOM ---
func _on_hitbox_enemigo_body_entered(body: Node2D) -> void:
	# Si el enemigo ya está muerto, no debería poder lastimar a Tom en el piso
	if is_dead: 
		return
		
	if body.has_method("recibir_danio"):
		body.recibir_danio(1, global_position.x)


# --- NUEVA FUNCIÓN: RECIBIR DAÑO (Para que Tom pueda golpear al enemigo) ---
# Cuando crees el golpe de Tom, su hitbox debe llamar a esta función en el enemigo
func recibir_danio(cantidad_danio: int) -> void:
	if is_dead:
		return
		
	vida -= cantidad_danio
	print("¡Enemigo golpeado! Vida restante: ", vida)
	
	if vida <= 0:
		_morir()


# --- NUEVA FUNCIÓN: MUERTE DEL ENEMIGO ---
func _morir():
	is_dead = true
	velocity = Vector2.ZERO # Lo frena en el sitio
	
	# Asegúrate de que el enemigo tenga la animación "death" en su AnimatedSprite2D
	_animated_sprite.play("death") 
	print("¡El enemigo ha muerto! Cerrando el juego...")
	
	# Espera a que termine de reproducirse la animación de muerte completa
	await _animated_sprite.animation_finished
	
	# Cierra la ventana del juego por completo
	get_tree().quit()
