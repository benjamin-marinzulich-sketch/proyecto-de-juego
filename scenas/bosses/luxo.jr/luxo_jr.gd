extends CharacterBody2D


var SPEED = 150.0
var HOP_VELOCITY = -370.0
const PAUSE_DURATION = 0.4

var is_landing_paused = false
var was_on_floor = true
var direction = 1


var vida = 12
var is_dead = false
var is_attacking = false

var escudo_inicio = true


var fase_actual = 1
var esta_enrabiado = false
var ya_revivio = false


@onready var _animated_sprite = $AnimatedSprite2D
@onready var _hitbox_danio_collision = $HitboxEnemigo/CollisionShape2D

@onready var _rayo_bate = $RayoBate
@onready var _rayo_collision = $RayoBate/RayoCollision
@onready var _rayo_sprite = $RayoBate/RayoSprite


func _ready() -> void:

	_rayo_collision.disabled = true
	_rayo_sprite.visible = false
	_rayo_bate.body_entered.connect(_on_rayo_bate_body_entered)

	await get_tree().create_timer(0.1).timeout
	escudo_inicio = false


func _physics_process(delta: float) -> void:

	if is_dead:
		if not is_on_floor():
			velocity += get_gravity() * delta
		velocity.x = 0
		move_and_slide()
		return


	if is_attacking:
		velocity.x = 0
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return


	if esta_enrabiado:
		velocity.x = 0
		if not is_on_floor():
			velocity += get_gravity() * delta
		else:
			velocity.y = HOP_VELOCITY * 0.8
			_animated_sprite.play("hop_up")
		move_and_slide()
		return


	if not is_on_floor():
		velocity += get_gravity() * delta
		_hitbox_danio_collision.shape.size = Vector2(64.0, 128.0)


	if is_on_floor():
		if not was_on_floor:
			_trigger_landing_stomp()
		was_on_floor = true
		_hitbox_danio_collision.shape.size = Vector2(104.0, 128.0)
	else:
		was_on_floor = false


	if is_landing_paused:
		velocity.x = 0
		_animated_sprite.play("hop_land")
		move_and_slide()
		return


	if is_on_wall():
		direction *= -1
		if fase_actual == 2:
			_ejecutar_ataque_rayo()
			return

	velocity.x = direction * SPEED
	_animated_sprite.flip_h = direction > 0

	if is_on_floor():
		velocity.y = HOP_VELOCITY


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



func _on_hitbox_enemigo_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.has_method("recibir_danio"):
		body.recibir_danio(1, global_position.x)



func recibir_danio(cantidad_danio: int) -> void:

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

	_animated_sprite.play("hop_land") 
	await get_tree().create_timer(1.5).timeout 

	fase_actual = 2
	vida = 5 
	SPEED += 60
	HOP_VELOCITY *= 1.15

	esta_enrabiado = false



func _ejecutar_ataque_rayo() -> void:
	is_attacking = true
	velocity = Vector2.ZERO

	_animated_sprite.flip_h = direction < 0

	await _reproducir_y_esperar(_animated_sprite, "carga", 0.6)

	_rayo_bate.scale.x = direction
	_rayo_sprite.visible = true
	if _rayo_sprite.sprite_frames and _rayo_sprite.sprite_frames.has_animation("disparo"):
		_rayo_sprite.play("disparo")


	const DELAY_ANTES_DE_DANAR = 0.5
	const DURACION_VENTANA_DANO = 0.3
	

	await get_tree().create_timer(DELAY_ANTES_DE_DANAR).timeout
	_rayo_collision.disabled = false


	await get_tree().physics_frame
	for body in _rayo_bate.get_overlapping_bodies():
		_on_rayo_bate_body_entered(body)

	await get_tree().create_timer(DURACION_VENTANA_DANO).timeout
	_rayo_collision.disabled = true

	if _rayo_sprite.sprite_frames and _rayo_sprite.sprite_frames.has_animation("disparo"):
		if _rayo_sprite.is_playing():
			await _rayo_sprite.animation_finished
	else:
		push_warning("⚠️ Falta la animación 'disparo' en RayoSprite")


	_rayo_sprite.visible = false
	_rayo_collision.disabled = true
	is_attacking = false



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
	pass

func _morir():
	is_dead = true
	velocity = Vector2.ZERO
	_animated_sprite.play("death")
	print("¡El enemigo ha muerto! Cerrando el juego...")
	await _animated_sprite.animation_finished
	get_tree().change_scene_to_file("res://scenas/ui/menu principal/Menuprincipal.tscn")
