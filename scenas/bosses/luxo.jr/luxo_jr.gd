extends CharacterBody2D

const SPEED = 150.0 
const HOP_VELOCITY = -400.0 
const PAUSE_DURATION = 0.4 

var is_landing_paused = false 
var was_on_floor = true 
var direction = 1 

# --- NUEVAS VARIABLES DE SALUD DEL ENEMIGO ---
var vida = 10
var is_dead = false

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _hitbox_danio_collision = $HitboxEnemigo/CollisionShape2D

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
		
		# 📈 EN EL AIRE: Se estira hacia arriba y se hace más delgado (Tipo Slime)
		# Ajusta el Vector2(ancho, alto) a los píxeles que le queden bien a tu sprite
		_hitbox_danio_collision.shape.size = Vector2(64.0, 128.0)
	
	# 2. Detector de impacto (Aterrizaje)
	if is_on_floor():
		if not was_on_floor:
			_trigger_landing_stomp()
		was_on_floor = true
		
		# 📉 EN EL SUELO: Si está caminando normal o pausado, recupera su ancho base o se aplasta
		if is_landing_paused:
			# Mientras hace el pisotón (impacto contra el suelo), se vuelve MUY ancho y petaco
			_hitbox_danio_collision.shape.size = Vector2(104.0, 128.0)
		else:
			# Cuando camina normal, vuelve a su tamaño estándar de rectángulo
			_hitbox_danio_collision.shape.size = Vector2(104.0, 128.0)
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


# --- FUNCIÓN: RECIBIR DAÑO (Modificada con efecto de brillo/tintineo) ---
func recibir_danio(cantidad_danio: int) -> void:
	if is_dead:
		return
		
	vida -= cantidad_danio
	print("¡Boss golpeado! Vida restante: ", vida)
	
	# 🔥 NUEVO: Activamos el tintineo visual de impacto
	_efecto_brillo_golpe()
	
	if vida <= 0:
		_morir()


# --- NUEVA RUTINA: EFECTO DE TINTINEO VISUAL ---
func _efecto_brillo_golpe() -> void:
	# Hacemos que el boss parpadee volviéndose semi-transparente y rojo por un instante
	# Puedes cambiar el Color(2, 0.5, 0.5) para ajustar el tono del brillo
	
	# Primer parpadeo rápido
	_animated_sprite.modulate = Color(3.0, 0.3, 0.3, 1.0) # Se vuelve rojo brillante (HDR)
	await get_tree().create_timer(0.05).timeout
	
	_animated_sprite.modulate = Color(1.0, 1.0, 1.0, 0.2) # Se vuelve casi invisible
	await get_tree().create_timer(0.05).timeout
	
	# Segundo parpadeo rápido
	_animated_sprite.modulate = Color(3.0, 0.3, 0.3, 1.0)
	await get_tree().create_timer(0.05).timeout
	
	# Devolvemos al boss a su color e intensidad original obligatoriamente
	_animated_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)


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
