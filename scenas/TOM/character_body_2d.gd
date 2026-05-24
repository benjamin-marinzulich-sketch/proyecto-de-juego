extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -300.0

# Referencia al nodo de animación (asegúrate de que se llame así en tu escena)
@onready var _animated_sprite = $AnimatedSprite2D

# Obtener la gravedad de los ajustes del proyecto
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# 1. Aplicar Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Manejar Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Movimiento Horizontal
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		# Voltear el sprite según la dirección
		_animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 4. Control de Animaciones
	if not is_on_floor():
		_animated_sprite.play("jump")
	elif velocity.x != 0:
		_animated_sprite.play("walk")
	else:
		_animated_sprite.play("idle")

	# 5. Ejecutar Movimiento
	move_and_slide()
