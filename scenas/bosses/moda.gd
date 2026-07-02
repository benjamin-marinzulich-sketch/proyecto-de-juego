extends "res://scenas/bosses/boss_actor.gd"

enum Fase { INICIO, PELEA }
var fase_actual = Fase.INICIO
var timer_inicio = 3.0
var tiempo_batalla = 0.0 # Cronómetro invisible de la pelea

func _ready() -> void:
	boss_display_name = "Moda"
	base_max_vida = 11
	base_speed = 78.0
	base_damage = 1
	attack_range = 40.0
	
	# 👇 AUMENTA ESTE NÚMERO (Ej: 1.5 o 2.0 segundos de espera entre golpes)
	attack_cooldown = 1.5 
	
	has_special_attack = true
	special_attack_range = 40.0
	
	# 👇 AUMENTA ESTE NÚMERO (Ej: 3.5 segundos de espera para la patada)
	special_attack_cooldown = 3.5 
	special_damage = 2
	special_lunge_speed = 0.0
	
	super._ready()
	_animated_sprite.play("inicioBatalla")

# Tomamos el control absoluto del movimiento de Moda
func _physics_process(delta: float) -> void:
	if is_dead:
		super._physics_process(delta)
		return

	# Gravedad estándar de Godot
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta

	match fase_actual:
		# --- FASE 1: LOS 3 SEGUNDOS DE ESPERA ---
		Fase.INICIO:
			velocity.x = 0
			timer_inicio -= delta

			# Si la animación de inicio ya terminó y aún no pasan los 3s,
			# la ponemos en "idle" (respirando) para que no se quede congelada.
			if not _animated_sprite.is_playing():
				_animated_sprite.play("idle")

			if timer_inicio <= 0:
				fase_actual = Fase.PELEA

		# --- FASE 2: PERSECUCIÓN Y COMBATE ---
		Fase.PELEA:
			tiempo_batalla += delta

			if attack_timer > 0: attack_timer -= delta
			if special_timer > 0: special_timer -= delta

			# 👇 NUEVO: SEGURO ANTITRABE 👇
			# Si el cerebro cree que ataca, pero la animación ya no es de ataque, la destrabamos a la fuerza
			if is_attacking and _animated_sprite.animation != "attack":
				is_attacking = false
			if is_special_attacking and _animated_sprite.animation != "special":
				is_special_attacking = false

			var player = get_tree().get_first_node_in_group("player")
			# ... (el resto del código sigue igual)

			# Si está en medio de un ataque, le prohibimos caminar
			if is_attacking or is_special_attacking:
				velocity.x = 0
			elif player:
				var distancia = abs(player.global_position.x - global_position.x)
				var direccion = sign(player.global_position.x - global_position.x)

				# Hacer que Moda mire siempre a Tom
				_animated_sprite.flip_h = direccion < 0

				# 1. Decide si lanzar ataque especial (Patada)
				if special_timer <= 0 and distancia <= special_attack_range:
					_start_special_attack(player)
				# 2. Decide si lanzar ataque normal (Golpe)
				elif attack_timer <= 0 and distancia <= attack_range:
					_start_attack(player)
				# 3. PERSEGUIR A TOM SI ESTÁ LEJOS (¡El fix a tu problema!)
				else:
					if distancia > attack_range:
						velocity.x = direccion * speed
						if _animated_sprite.animation != "run":
							_animated_sprite.play("run")
					else:
						velocity.x = 0
						if _animated_sprite.animation != "idle":
							_animated_sprite.play("idle")
			else:
				velocity.x = 0

	move_and_slide()


# --- SOBRESCRIBIMOS LA MUERTE PARA AGREGAR EL CRONÓMETRO ---
func _die() -> void:
	# 1. 👇 SEGURO ANTICRASH: Si ya está muerta, ignoramos los golpes extra
	if is_dead:
		return
		
	is_dead = true
	velocity = Vector2.ZERO
	_animated_sprite.play("death")
	died.emit()

	# 2. Le decimos a Tom que empiece a celebrar
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("celebrar_victoria"):
		player.celebrar_victoria()

	# 3. Calculamos el tiempo en minutos y segundos
	var minutos = int(tiempo_batalla) / 60
	var segundos = int(tiempo_batalla) % 60
	var tiempo_texto = "%02d:%02d" % [minutos, segundos]

	# 4. Esperamos a que la animación de muerte de Moda termine
	await _animated_sprite.animation_finished
	
	# 5. 👇 TIEMPO EXTRA PARA TOM: Le damos 1.5s para que su animación 'win' termine de cargar
	await get_tree().create_timer(1.5).timeout

	# 6. Notificamos a la pantalla de resultados
	GameState.complete_selected_boss()
	var detalle_resultado = "¡Victoria! Le ganaste a Moda en " + tiempo_texto
	GameState.set_battle_result("victory", "¡Moda Derrotada!", detalle_resultado)
	
	# 7. 👇 CAMBIO SEGURO: call_deferred evita que Godot colapse al cambiar de escena
	get_tree().call_deferred("change_scene_to_file", GameState.RESULT_SCREEN_PATH)
