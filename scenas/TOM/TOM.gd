extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -400.0
var can_dash = true # Nos dice si Tom tiene permitido dashear

var vida = 3 # Los 5 corazones o puntos de vida de Tom
var is_dead = false # Nos dice si Tom ya pasó a mejor vida
var hurt_timer = 0.0  # Lleva la cuenta de cuánto tiempo lleva herido
# NUEVO: Ajustes para el Dash
const DASH_SPEED = 280.0 # Es más del doble de rápido que caminar
var is_dashing = false

const HURT_KNOCKBACK_X = 250.0 # Fuerza del empujón hacia atrás
const HURT_KNOCKBACK_Y = -300.0 # Fuerza del saltito hacia arriba al recibir daño
const INVULNERABILITY_TIME = 1.5 # Segundos de inmunidad tras el golpe

var is_hurt = false # Bloquea los controles mientras Tom sufre el golpe
var is_invulnerable = false # Evita recibir daño seguido si ya te golpearon

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
		velocity.x = 0 # Evita que se mueva de lado al morir
		move_and_slide()
		return
		
	if is_on_floor():
		can_dash = true
	# 1. Aplicar Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. NUEVO SISTEMA DE CONTROL DE DAÑO POR DELTA
	if is_hurt:
		_animated_sprite.play("hurt")
		
		# Restamos tiempo frame a frame
		hurt_timer -= delta
		
		# Si el tiempo llegó a 0, le devolvemos el control obligatoriamente
		if hurt_timer <= 0.0:
			is_hurt = false
			velocity.x = 0 # Frenamos el impulso del golpe para que vuelva a la normalidad
			
		move_and_slide()
		return # Bloquea el teclado mientras dure el contador
		
	# 2. Manejar Salto (Solo si no está atacando ni dasheando)
	if not is_dashing and not is_attacking:
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		if Input.is_action_just_released("ui_accept") and velocity.y < 0:
			velocity.y *= 0.5

	# 3. Activar Ataque (Solo si no está ya dasheando)
	if Input.is_action_just_pressed("attack") and not is_attacking and not is_dashing:
		is_attacking = true
		_animated_sprite.play("atack")
		_hitbox_collision.set_deferred("disabled", false)

	# 3.5. Activar Dash / Voltereta
	if Input.is_action_just_pressed("dash") and not is_dashing and not is_attacking and can_dash:
		if not is_on_floor():
			can_dash = false
			
		is_dashing = true
		_animated_sprite.play("dash") 
		velocity.y = 0 
		
		var facing_direction = -1.0 if _animated_sprite.flip_h else 1.0
		velocity.x = facing_direction * DASH_SPEED

	# 4. Movimiento Horizontal
	if not is_dashing: 
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
			_animated_sprite.flip_h = direction < 0
			
			# MEJORA RADICAL DEL BATE: En vez de escalar, movemos la posición X
			# Ajusta el 35.0 si necesitas que el bate llegue todavía más lejos
			if direction < 0:
				_hitbox.position.x = -35.0  
			else:
				_hitbox.position.x = 35.0  
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		var facing_direction = -1.0 if _animated_sprite.flip_h else 1.0
		velocity.x = facing_direction * DASH_SPEED

	# 5. Control de Animaciones
	if not is_attacking and not is_dashing:
		if not is_on_floor():
			_animated_sprite.play("jump")
		elif velocity.x != 0:
			_animated_sprite.play("walk")
		else:
			_animated_sprite.play("idle")

	# 6. Ejecutar Movimiento
	move_and_slide()

# Se ejecuta automáticamente al terminar CUALQUIER animación
func _on_animation_finished():
	if _animated_sprite.animation == "atack":
		is_attacking = false
		_hitbox_collision.set_deferred("disabled", true)
		
	if _animated_sprite.animation == "dash":
		is_dashing = false

# --- DETECTOR DE BATAZO: Aquí Tom le pega al enemigo (Boss) ---
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == self:
		return

	if body.has_method("recibir_danio"):
		# Le hacemos 1 de daño al jefe, pero NO lo movemos ni un milímetro
		body.recibir_danio(1)
		print("¡Tom le dio un tremendo batazo a ", body.name, "!")
		
	else:
		print("Tocaste algo que no se puede dañar: ", body.name)

# --- FUNCIÓN DE RECIBIR DAÑO ---
func recibir_danio(cantidad_danio: int, enemigo_pos_x: float) -> void:
	if is_dead or is_hurt or is_invulnerable:
		return
		
	is_dashing = false 
	is_attacking = false 
	
	vida -= cantidad_danio
	print("¡Tom fue golpeado! Vida restante: ", vida)
	
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

# --- RUTINA DE INVULNERABILIDAD ---
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
	
	
