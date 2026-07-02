extends CharacterBody2D

# --- CONFIGURACIÓN DE VELOCIDADES ---
var SPEED = 150.0
var HOP_VELOCITY = -400.0
const PAUSE_DURATION = 0.4

var is_landing_paused = false
var was_on_floor = true
var direction = 1

# --- SISTEMA DE FASES Y ENERGÍA ---
var vida = 10
var is_dead = false
var is_attacking = false

var escudo_inicio = true

# VARIABLES PARA LA FASE 2 Y BERRINCHE
var fase_actual = 1
var esta_enrabiado = false
var ya_revivio = false

# 🌟 NODOS
@onready var _animated_sprite = $AnimatedSprite2D
@onready var _hitbox_danio_collision = $HitboxEnemigo/CollisionShape2D

@onready var _rayo_bate = $RayoBate
@onready var _rayo_collision = $RayoBate/RayoCollision
@onready var _rayo_sprite = $RayoBate/RayoSprite


func _ready() -> void:
	# 🔧 FIX: ocultar el rayo ANTES del await, si no se ve un frame suelto al iniciar el nivel
	_rayo_collision.disabled = true
	_rayo_sprite.visible = false
	_rayo_bate.body_entered.connect(_on_rayo_bate_body_entered)

	await get_tree().create_timer(0.1).timeout
	escudo_inicio = false


func _physics_process(delta: float) -> void:
	# 🪦 MUERTE: apaga toda la IA
	if is_dead:
		if not is_on_floor():
			velocity += get_gravity() * delta
		velocity.x = 0
		move_and_slide()
		return

	# ⚡ Congelado mientras carga/dispara el rayo
	if is_attacking:
		velocity.x = 0
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return

	# 😡 BERRINCHE: salta en el sitio, sin moverse a los lados
	if esta_enrabiado:
		velocity.x = 0
		if not is_on_floor():
			velocity += get_gravity() * delta
		else:
			velocity.y = HOP_VELOCITY * 0.8
			_animated_sprite.play("hop_up")
		move_and_slide()
		return

	# 1. Gravedad + hitbox delgado en el aire
	if not is_on_floor():
		velocity += get_gravity() * delta
		_hitbox_danio_collision.shape.size = Vector2(64.0, 128.0)

	# 2. Aterrizaje
	if is_on_floor():
		if not was_on_floor:
			_trigger_landing_stomp()
		was_on_floor = true
		_hitbox_danio_collision.shape.size = Vector2(104.0, 128.0)
	else:
		was_on_floor = false

	# 3. Pausa por pisotón
	if is_landing_paused:
		velocity.x = 0
		_animated_sprite.play("hop_land")
		move_and_slide()
		return

	# 4. Choque con pared: gira y, en fase 2, dispara el rayo
	if is_on_wall():
		direction *= -1
		if fase_actual == 2:
			_ejecutar_ataque_rayo()
			return

	velocity.x = direction * SPEED
	_animated_sprite.flip_h = direction > 0

	if is_on_floor():
		velocity.y = HOP_VELOCITY

	# 5. Animaciones de movimiento
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


# --- CONTACTO DIRECTO CONTRA TOM ---
func _on_hitbox_enemigo_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.has_method("recibir_danio"):
		body.recibir_danio(1, global_position.x)


# --- RECIBIR DAÑO ---
func recibir_danio(cantidad_danio: int) -> void:
	# 🔧 FIX: agregado 'esta_enrabiado' — sin esto, un golpe durante el berrinche
	# lo mataba directo porque la vida todavía no se había recargado a 10.
	if is_dead or is_attacking or esta_enrabiado:
		return

	vida -= cantidad_danio
	print("¡Boss golpeado! Vida restante: ", vida)

	_efecto_brillo_golpe()

	if vida <= 0:
		if fase_actual == 1 and not ya_revivio:
			ya_revivio = true
			_iniciar_berrinche()
		else:
			_morir()


func _efecto_brillo_golpe() -> void:
	_animated_sprite.modulate = Color(3.0, 0.3, 0.3, 1.0)
	await get_tree().create_timer(0.05).timeout
	_animated_sprite.modulate = Color(1.0, 1.0, 1.0, 0.2)
	await get_tree().create_timer(0.05).timeout
	_animated_sprite.modulate = Color(3.0, 0.3, 0.3, 1.0)
	await get_tree().create_timer(0.05).timeout
	_animated_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)


# --- BERRINCHE: aviso de cambio de fase ---
func _iniciar_berrinche() -> void:
	esta_enrabiado = true
	print("¡El boss entró en fase de furia!")

	_animated_sprite.play("hop_land")  # puedes cambiarla por una animación propia de rabieta
	await get_tree().create_timer(1.5).timeout  # duración del berrinche, ajústala a gusto

	fase_actual = 2
	vida = 5  # nueva "barra" de vida para la fase 2, ajústala a gusto
	SPEED += 60
	HOP_VELOCITY *= 1.15

	esta_enrabiado = false


# --- ATAQUE DE RAYO (fase 2, al chocar con pared) ---
func _ejecutar_ataque_rayo() -> void:
	is_attacking = true
	velocity = Vector2.ZERO

	# 🔧 FIX: actualiza la orientación ANTES de cargar, porque 'direction'
	# ya cambió arriba (is_on_wall) y esta línea nunca se alcanzaba antes.
	# Tus frames miran a la izquierda por defecto, así que:
	# direction > 0  -> mirando a la derecha -> hay que flippear (true)
	# direction < 0  -> mirando a la izquierda (frames originales) -> false
	_animated_sprite.flip_h = direction < 0

	# 1. Animación de carga (tus 4 frames de attack2.png)
	await _reproducir_y_esperar(_animated_sprite, "carga", 0.6)

	# 2. Orienta y muestra el rayo hacia donde mira el boss (todavía sin dañar)
	_rayo_bate.scale.x = direction
	_rayo_sprite.visible = true
	if _rayo_sprite.sprite_frames and _rayo_sprite.sprite_frames.has_animation("disparo"):
		_rayo_sprite.play("disparo")

	# 🦘 VENTANA DE DAÑO ESQUIVABLE:
	# El hitbox se activa DESPUÉS de un pequeño delay (para que Tom vea el rayo
	# aparecer y todavía pueda saltar) y solo dura un instante corto, no toda
	# la animación. Ajusta estos dos números a lo que se sienta justo:
	#   - DELAY_ANTES_DE_DANAR: tiempo desde que se ve el rayo hasta que empieza a dañar
	#   - DURACION_VENTANA_DANO: cuánto tiempo se puede recibir daño
	const DELAY_ANTES_DE_DANAR = 0.2
	const DURACION_VENTANA_DANO = 0.2

	await get_tree().create_timer(DELAY_ANTES_DE_DANAR).timeout
	_rayo_collision.disabled = false

	# Chequeo manual por si Tom ya estaba parado ahí cuando se activó
	await get_tree().physics_frame
	for body in _rayo_bate.get_overlapping_bodies():
		_on_rayo_bate_body_entered(body)

	await get_tree().create_timer(DURACION_VENTANA_DANO).timeout
	_rayo_collision.disabled = true

	# 3. Deja que la animación visual del rayo termine de reproducirse
	#    (aunque ya no dañe, para que no se corte de golpe)
	if _rayo_sprite.sprite_frames and _rayo_sprite.sprite_frames.has_animation("disparo"):
		if _rayo_sprite.is_playing():
			await _rayo_sprite.animation_finished
	else:
		push_warning("⚠️ Falta la animación 'disparo' en RayoSprite")

	# 4. Apaga el rayo y devuelve el control
	_rayo_sprite.visible = false
	_rayo_collision.disabled = true
	is_attacking = false


# 🛟 SEGURO ANTI-TRABAS: reproduce una animación y espera a que termine,
# pero si la animación no existe en el SpriteFrames, avisa en consola
# y espera un tiempo fijo en vez de quedarse colgado para siempre.
func _reproducir_y_esperar(sprite: AnimatedSprite2D, anim_name: String, tiempo_fallback: float) -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
		await sprite.animation_finished
	else:
		push_warning("⚠️ Falta la animación '%s' en %s — usando espera de respaldo" % [anim_name, sprite.name])
		await get_tree().create_timer(tiempo_fallback).timeout


func _on_rayo_bate_body_entered(body: Node2D) -> void:
	if body.has_method("recibir_danio"):
		body.recibir_danio(1, global_position.x)


func _on_rayo_sprite_animation_finished() -> void:
	pass # ya lo manejamos con await en _ejecutar_ataque_rayo, no hace falta código aquí


# --- MUERTE (fase 2 final) ---
func _morir():
	is_dead = true
	velocity = Vector2.ZERO
	_animated_sprite.play("death")
	print("¡El enemigo ha muerto! Cerrando el juego...")
	await _animated_sprite.animation_finished
	get_tree().quit()
