extends CharacterBody2D

signal vida_cambiada(nueva_vida) 

const SPEED = 120.0
const JUMP_VELOCITY = -400.0
var can_dash = true

var vida = 3 
var is_dead = false 
var hurt_timer = 0.0  

const DASH_SPEED = 280.0
var is_dashing = false

const HURT_KNOCKBACK_X = 250.0 
const HURT_KNOCKBACK_Y = -300.0 
const INVULNERABILITY_TIME = 1.5 

var is_hurt = false 
var is_invulnerable = false 

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _hitbox = $Area2D 
@onready var _hitbox_collision = $Area2D/CollisionShape2D 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking = false 

func _ready():
	_animated_sprite.animation_finished.connect(_on_animation_finished)
	_hitbox_collision.disabled = true

func _physics_process(delta):
	if is_dead:
		if not is_on_floor():
			velocity += get_gravity() * delta
		velocity.x = 0
		move_and_slide()
		return
		
	if is_on_floor():
		can_dash = true

	if not is_on_floor():
		velocity += get_gravity() * delta


	if is_hurt:
		_animated_sprite.play("hurt")
		

		hurt_timer -= delta
		

		if hurt_timer <= 0.0:
			is_hurt = false
			velocity.x = 0 
			
		move_and_slide()
		return 
		

	if not is_dashing and not is_attacking:
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		if Input.is_action_just_released("ui_accept") and velocity.y < 0:
			velocity.y *= 0.5


	if Input.is_action_just_pressed("attack") and not is_attacking and not is_dashing:
		is_attacking = true
		_animated_sprite.play("atack")
		_hitbox_collision.set_deferred("disabled", false)


	if Input.is_action_just_pressed("dash") and not is_dashing and not is_attacking and can_dash:
		if not is_on_floor():
			can_dash = false
			
		is_dashing = true
		_animated_sprite.play("dash") 
		velocity.y = 0 
		
		var facing_direction = -1.0 if _animated_sprite.flip_h else 1.0
		velocity.x = facing_direction * DASH_SPEED


	if not is_dashing: 
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
			_animated_sprite.flip_h = direction < 0
			

			if direction < 0:

				_hitbox.position.x = -50.0  
			else:

				_hitbox.position.x = 10.0  
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		var facing_direction = -1.0 if _animated_sprite.flip_h else 1.0
		velocity.x = facing_direction * DASH_SPEED


	if not is_attacking and not is_dashing:
		if not is_on_floor():
			_animated_sprite.play("jump")
		elif velocity.x != 0:
			_animated_sprite.play("walk")
		else:
			_animated_sprite.play("idle")


	move_and_slide()


func _on_animation_finished():
	if _animated_sprite.animation == "atack":
		is_attacking = false
		_hitbox_collision.set_deferred("disabled", true)
		
	if _animated_sprite.animation == "dash":
		is_dashing = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == self:
		return

	if body.has_method("recibir_danio"):
	
		body.recibir_danio(1)
		print("¡Tom le dio un tremendo batazo a ", body.name, "!")
		
	else:
		print("Tocaste algo que no se puede dañar: ", body.name)

func recibir_danio(cantidad_danio: int, enemigo_pos_x: float) -> void:
	if is_dead or is_hurt or is_invulnerable:
		return
		
	is_dashing = false 
	is_attacking = false 
	
	vida -= cantidad_danio
	print("¡Tom fue golpeado! Vida restante: ", vida)
	vida_cambiada.emit(vida)
	if vida <= 0:
		_morir()
		return 
		
	is_hurt = true
	hurt_timer = 0.3 
	_animated_sprite.play("hurt")
	
	var knockback_direction = -1.0 if enemigo_pos_x > global_position.x else 1.0
	velocity.x = knockback_direction * HURT_KNOCKBACK_X
	velocity.y = HURT_KNOCKBACK_Y 

	_trigger_invulnerability()


func _trigger_invulnerability():
	is_invulnerable = true
	for i in range(int(INVULNERABILITY_TIME * 5)):
		_animated_sprite.modulate.a = 0.3 if _animated_sprite.modulate.a == 1.0 else 1.0
		await get_tree().create_timer(0.15).timeout
	
	_animated_sprite.modulate.a = 1.0
	is_invulnerable = false

func _morir():
	is_dead = true
	velocity = Vector2.ZERO 
	_animated_sprite.play("death") 
	print("¡Game Over! Tom ha muerto.")
	
	await _animated_sprite.animation_finished
	get_tree().reload_current_scene()
	
	
