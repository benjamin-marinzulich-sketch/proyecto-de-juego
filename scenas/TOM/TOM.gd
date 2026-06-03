extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -400.0

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _hitbox = $Area2D # Asegúrate de usar $Area2D o $Hitbox según tu escena
@onready var _hitbox_collision = $Area2D/CollisionShape2D 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking = false 

func _ready():
	_animated_sprite.animation_finished.connect(_on_animation_finished)
	_hitbox_collision.disabled = true

func _physics_process(delta):
	# 1. Aplicar Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Manejar Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y *= 0.5

# 3. Activar Ataque
	if Input.is_action_just_pressed("attack") and not is_attacking:
		print("¡Botón presionado correctamente!") # <--- AGREGA ESTO
		is_attacking = true
		_animated_sprite.play("atack")
		_hitbox_collision.set_deferred("disabled", false)

	# 4. Movimiento Horizontal
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		
		# Volteamos el gráfico del personaje
		_animated_sprite.flip_h = direction < 0
		
		# NUEVO: Volteamos TODO el nodo de la hitbox como un espejo
		if direction < 0:
			_hitbox.scale.x = -1  # Apunta la hitbox a la izquierda
		else:
			_hitbox.scale.x = 1   # Apunta la hitbox a la derecha
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 5. Control de Animaciones
	if not is_attacking:
		if not is_on_floor():
			_animated_sprite.play("jump")
		elif velocity.x != 0:
			_animated_sprite.play("walk")
		else:
			_animated_sprite.play("idle")

	# 6. Ejecutar Movimiento
	move_and_slide()

# Se ejecuta al terminar la animación de ataque
func _on_animation_finished():
	if _animated_sprite.animation == "atack":
		is_attacking = false
		_hitbox_collision.set_deferred("disabled", true)

# Detectar el golpe al maniquí u otros cuerpos
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == self:
		return

	if body.has_method("recibir_danio"):
		body.recibir_danio(1)
		print("¡Tom golpeó a ", body.name, "!")
	else:
		print("Tocaste algo que no se puede dañar: ", body.name)
