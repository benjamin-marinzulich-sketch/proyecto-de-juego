extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -400.0
var can_dash = true # Nos dice si Tom tiene permitido dashear

# NUEVO: Ajustes para el Dash
const DASH_SPEED = 280.0 # Es más del doble de rápido que caminar
var is_dashing = false

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _hitbox = $Area2D # Asegúrate de usar $Area2D o $Hitbox según tu escena
@onready var _hitbox_collision = $Area2D/CollisionShape2D 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking = false 

func _ready():
	_animated_sprite.animation_finished.connect(_on_animation_finished)
	_hitbox_collision.disabled = true

func _physics_process(delta):
	if is_on_floor():
		can_dash = true
	# 1. Aplicar Gravedad (NUEVO: Mientras dashea, ignora la gravedad para que no caiga pesado)
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta

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

# 3.5. NUEVO: Activar Dash / Voltereta
	# CAMBIO: Añadimos "and can_dash" al final de tu condición
	if Input.is_action_just_pressed("dash") and not is_dashing and not is_attacking and can_dash:
		
		# NUEVO: Si usa el dash en el aire, le quitamos el permiso hasta que toque el suelo
		if not is_on_floor():
			can_dash = false
			
		is_dashing = true
		_animated_sprite.play("dash") # <--- Asegúrate de que tu animación se llame exactamente "dash"
		velocity.y = 0 # Ponemos a cero la velocidad vertical para un dash limpio en el aire
		
		# Calculamos hacia dónde está mirando Tom para empujarlo en esa dirección
		var facing_direction = -1.0 if _animated_sprite.flip_h else 1.0
		velocity.x = facing_direction * DASH_SPEED

	# 4. Movimiento Horizontal
	if not is_dashing: # Si está dasheando, bloqueamos el control del teclado
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
			_animated_sprite.flip_h = direction < 0
			
			if direction < 0:
				_hitbox.scale.x = -1 
			else:
				_hitbox.scale.x = 1 
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		# Mientras dashea, mantiene su velocidad fija de dash hacia adelante
		var facing_direction = -1.0 if _animated_sprite.flip_h else 1.0
		velocity.x = facing_direction * DASH_SPEED

	# 5. Control de Animaciones (NUEVO: Agregamos 'and not is_dashing')
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
		
	# NUEVO: Al terminar la vuelta del dash, le devolvemos el control al jugador
	if _animated_sprite.animation == "dash":
		is_dashing = false

# Detectar el golpe al maniquí u otros cuerpos
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == self:
		return

	if body.has_method("recibir_danio"):
		body.recibir_danio(1)
		print("¡Tom golpeó a ", body.name, "!")
	else:
		print("Tocaste algo que no se puede dañar: ", body.name)
