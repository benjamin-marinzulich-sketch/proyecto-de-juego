extends CharacterBody2D

signal health_changed(current_health: int, max_health: int)
signal died

const GRAVITY := 980.0
const ATTACK_RANGE := 70.0
const ATTACK_COOLDOWN := 1.0

@export var boss_display_name := "Rata de Prueba"
@export var max_vida := 8
@export var speed := 70.0
@export var damage := 1
@export var result_detail := "El jefe de prueba fue derrotado."

var vida := 8
var direction := 1.0
var attack_timer := 0.0
var is_dead := false
var is_attacking := false

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("boss")
	vida = max_vida
	_animated_sprite.animation_finished.connect(_on_animation_finished)
	health_changed.emit(vida, max_vida)

func _physics_process(delta: float) -> void:
	if is_dead:
		_apply_gravity(delta)
		velocity.x = 0.0
		move_and_slide()
		return

	_apply_gravity(delta)
	attack_timer = max(attack_timer - delta, 0.0)

	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player:
		direction = sign(player.global_position.x - global_position.x)
		if direction == 0.0:
			direction = 1.0

		if global_position.distance_to(player.global_position) <= ATTACK_RANGE and attack_timer <= 0.0:
			_attack_player(player)

	if is_attacking:
		velocity.x = 0.0
	else:
		velocity.x = direction * speed
		if is_on_wall():
			direction *= -1.0
		_animated_sprite.flip_h = direction < 0.0
		_animated_sprite.play("run" if abs(velocity.x) > 0.0 else "idle")

	move_and_slide()

func recibir_danio(cantidad_danio: int) -> void:
	if is_dead:
		return

	vida = max(vida - cantidad_danio, 0)
	health_changed.emit(vida, max_vida)
	AudioManager.play_hit()
	_flash_hit()

	if vida <= 0:
		_die()

func _attack_player(player: Node2D) -> void:
	is_attacking = true
	attack_timer = ATTACK_COOLDOWN
	_animated_sprite.play("attack")
	AudioManager.play_attack()

	if player.has_method("recibir_danio"):
		player.recibir_danio(damage, global_position.x)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func _flash_hit() -> void:
	_animated_sprite.modulate = Color(3.0, 0.3, 0.3, 1.0)
	await get_tree().create_timer(0.08).timeout
	if not is_dead:
		_animated_sprite.modulate = Color.WHITE

func _die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	_animated_sprite.play("death")
	died.emit()

	await _animated_sprite.animation_finished
	GameState.complete_selected_boss()
	GameState.set_battle_result("victory", "Victoria", result_detail)
	get_tree().change_scene_to_file("res://scenas/ui/result/ResultScreen.tscn")

func _on_animation_finished() -> void:
	if _animated_sprite.animation == "attack":
		is_attacking = false
