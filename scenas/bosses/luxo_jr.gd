extends CharacterBody2D

signal health_changed(current_health: int, max_health: int)
signal died

const SPEED := 150.0
const HOP_VELOCITY := -400.0
const PAUSE_DURATION := 0.4

@export var max_vida := 10

var vida := 10
var is_landing_paused := false
var was_on_floor := true
var direction := 1
var is_dead := false

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _hitbox_danio_collision: CollisionShape2D = $HitboxEnemigo/CollisionShape2D

func _ready() -> void:
	add_to_group("boss")
	vida = max_vida
	health_changed.emit(vida, max_vida)

func _physics_process(delta: float) -> void:
	if is_dead:
		if not is_on_floor():
			velocity += get_gravity() * delta
		velocity.x = 0
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

func _trigger_landing_stomp() -> void:
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
	if is_dead:
		return

	vida = max(vida - cantidad_danio, 0)
	health_changed.emit(vida, max_vida)
	AudioManager.play_hit()
	_efecto_brillo_golpe()

	if vida <= 0:
		_morir()

func _efecto_brillo_golpe() -> void:
	_animated_sprite.modulate = Color(3.0, 0.3, 0.3, 1.0)
	await get_tree().create_timer(0.05).timeout
	_animated_sprite.modulate = Color(1.0, 1.0, 1.0, 0.2)
	await get_tree().create_timer(0.05).timeout
	_animated_sprite.modulate = Color(3.0, 0.3, 0.3, 1.0)
	await get_tree().create_timer(0.05).timeout
	_animated_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _morir() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	_animated_sprite.play("death")
	died.emit()

	await _animated_sprite.animation_finished
	GameState.complete_selected_boss()
	GameState.set_battle_result("victory", "Victoria", "Luxy Junior fue derrotado. Nuevas peleas quedan desbloqueadas cuando esten implementadas.")
	get_tree().change_scene_to_file("res://scenas/ui/result/ResultScreen.tscn")
