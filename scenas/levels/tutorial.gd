extends Node2D

@onready var label_conteo: Label = $CanvasLayer/LabelConteo

var tiempo_restante := 3

func _ready() -> void:
	_spawn_selected_boss()
	AudioManager.play_battle_music()
	_orient_combatants()
	_set_combatants_physics(false)
	label_conteo.text = str(tiempo_restante)
	_iniciar_cuenta_regresiva()

func _spawn_selected_boss() -> void:
	if GameState.selected_boss_index == 0:
		return

	var boss_path := GameState.get_selected_boss_actor_scene_path()
	if boss_path == "":
		return

	var current_boss := get_tree().get_first_node_in_group("boss") as Node2D
	if not current_boss:
		return

	var boss_position := current_boss.global_position
	current_boss.get_parent().remove_child(current_boss)
	current_boss.queue_free()

	var boss_scene := load(boss_path) as PackedScene
	if not boss_scene:
		return

	var boss := boss_scene.instantiate() as Node2D
	boss.global_position = boss_position + Vector2(0, 41)
	add_child(boss)

func _orient_combatants() -> void:
	var boss := get_tree().get_first_node_in_group("boss")
	var player := get_tree().get_first_node_in_group("player")

	if boss and boss.has_node("AnimatedSprite2D"):
		boss.get_node("AnimatedSprite2D").flip_h = true
	if player and player.has_node("AnimatedSprite2D"):
		player.get_node("AnimatedSprite2D").flip_h = true

func _set_combatants_physics(enabled: bool) -> void:
	for node in get_tree().get_nodes_in_group("boss"):
		node.set_physics_process(enabled)
	for node in get_tree().get_nodes_in_group("player"):
		node.set_physics_process(enabled)

func _iniciar_cuenta_regresiva() -> void:
	for i in range(3):
		await get_tree().create_timer(1.0).timeout
		tiempo_restante -= 1

		if tiempo_restante > 0:
			label_conteo.text = str(tiempo_restante)

	label_conteo.text = "READY!"
	await get_tree().create_timer(0.8).timeout
	label_conteo.visible = false
	_set_combatants_physics(true)
