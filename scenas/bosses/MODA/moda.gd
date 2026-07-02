extends CharacterBody2D


const SPEED = 110.0
const RANGO_ATAQUE = 30.0      
const RANGO_DETECCION = 140.0  

var direction = 1
var vida = 10                   
var is_dead = false
var is_attacking = false

var tom_ref = null  

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _hitbox_area = $Area2D
@onready var _hitbox_collision = $Area2D/CollisionShape2D


func _ready() -> void:
	_hitbox_area.body_entered.connect(_on_area_2d_body_entered)
	_hitbox_collision.disabled = true 

	
	var jugadores = get_tree().get_nodes_in_group("player")
	if jugadores.size() > 0:
		tom_ref = jugadores[0]
	else:
		push_warning("⚠️ Edna no encontró a Tom. Agrega a Tom al grupo 'player'.")


func _physics_process(delta: float) -> void:
	if is_dead:
		if not is_on_floor():
			velocity += get_gravity() * delta
		velocity.x = 0
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return


	if tom_ref == null or not is_instance_valid(tom_ref):
		_patrullar()
		move_and_slide()
		return

	var distancia = global_position.distance_to(tom_ref.global_position)

	if distancia <= RANGO_DETECCION:

		direction = 1 if tom_ref.global_position.x > global_position.x else -1
		_animated_sprite.flip_h = direction < 0

		if distancia <= RANGO_ATAQUE:
			_iniciar_ataque()
		else:
			velocity.x = direction * SPEED
			_animated_sprite.play("walk")
	else:
		_patrullar()

	move_and_slide()


func _patrullar() -> void:
	if is_on_wall():
		direction *= -1

	velocity.x = direction * SPEED
	_animated_sprite.flip_h = direction < 0
	_animated_sprite.play("walk")


func _iniciar_ataque() -> void:
	is_attacking = true
	velocity.x = 2

	_animated_sprite.play("atack")
	_hitbox_collision.set_deferred("disabled", false)

	if _animated_sprite.sprite_frames and _animated_sprite.sprite_frames.has_animation("atack"):
		await _animated_sprite.animation_finished
	else:
		push_warning("⚠️ Falta la animación 'atack' en Edna")
		await get_tree().create_timer(0.5).timeout

	_hitbox_collision.set_deferred("disabled", true)
	is_attacking = false



func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.has_method("recibir_danio"):
		body.recibir_danio(1, global_position.x)



func recibir_danio(cantidad_danio: int) -> void:
	if is_dead:
		return

	vida -= cantidad_danio
	print("¡Edna golpeada! Vida restante: ", vida)
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
	is_attacking = false
	_hitbox_collision.disabled = true

	_animated_sprite.play("death")

	if _animated_sprite.sprite_frames and _animated_sprite.sprite_frames.has_animation("death"):
		await _animated_sprite.animation_finished
	else:
		push_warning("⚠️ Falta la animación 'death' en Edna")
		await get_tree().create_timer(0.5).timeout

	get_tree().change_scene_to_file("res://scenas/ui/menu principal/Menuprincipal.tscn")
