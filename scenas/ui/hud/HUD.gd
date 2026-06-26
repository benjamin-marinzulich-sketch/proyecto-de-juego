extends CanvasLayer

const HEART_SCENE := preload("res://scenas/ui/hud/HeartIcon.tscn")

@onready var contenedor: HBoxContainer = $ContenedorCorazones

var boss_bar: ProgressBar
var boss_label: Label

func _ready() -> void:
	_build_boss_health()
	call_deferred("_connect_combatants")

func _build_boss_health() -> void:
	var panel := VBoxContainer.new()
	panel.name = "BossHealth"
	panel.anchor_left = 0.5
	panel.anchor_right = 1.0
	panel.offset_left = -170
	panel.offset_top = 8
	panel.offset_right = -10
	panel.offset_bottom = 42
	panel.add_theme_constant_override("separation", 2)
	add_child(panel)

	boss_label = Label.new()
	boss_label.text = GameState.get_selected_boss_name()
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	boss_label.add_theme_font_size_override("font_size", 10)
	panel.add_child(boss_label)

	boss_bar = ProgressBar.new()
	boss_bar.min_value = 0
	boss_bar.max_value = 10
	boss_bar.value = 10
	boss_bar.show_percentage = false
	boss_bar.custom_minimum_size = Vector2(160, 10)
	panel.add_child(boss_bar)

func _connect_combatants() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_player_health_changed)
		_on_player_health_changed(player.vida, player.max_vida)

	var boss := get_tree().get_first_node_in_group("boss")
	if boss:
		boss.health_changed.connect(_on_boss_health_changed)
		_on_boss_health_changed(boss.vida, boss.max_vida)

func _on_player_health_changed(current_health: int, max_health: int) -> void:
	_generate_hearts(current_health, max_health)

func _on_boss_health_changed(current_health: int, max_health: int) -> void:
	if not boss_bar:
		return
	boss_bar.max_value = max_health
	boss_bar.value = current_health

func _generate_hearts(current_health: int, max_health: int) -> void:
	for node in contenedor.get_children():
		node.queue_free()

	for i in range(max_health):
		var heart := HEART_SCENE.instantiate()
		heart.modulate.a = 1.0 if i < current_health else 0.25
		contenedor.add_child(heart)
