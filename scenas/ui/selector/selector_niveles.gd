extends Control

var boss_index := 0

var boss_label: Label
var status_label: Label
var detail_label: Label
var start_button: Button
var previous_button: Button
var next_button: Button
var difficulty_buttons := {}

const PANEL_SIZE := Vector2(270, 170)
const TITLE_FONT_SIZE := 12
const BOSS_FONT_SIZE := 10
const SMALL_FONT_SIZE := 7
const BUTTON_FONT_SIZE := 8

func _ready() -> void:
	boss_index = GameState.selected_boss_index
	_build_interface()
	_refresh()

func _build_interface() -> void:
	for child in get_children():
		child.queue_free()

	var background := TextureRect.new()
	background.texture = load("res://scenas/ui/assets/width_1536.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var frame := NinePatchRect.new()
	frame.texture = load("res://scenas/ui/assets/qweerr.png")
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.offset_left = 24
	frame.offset_top = 14
	frame.offset_right = -24
	frame.offset_bottom = -14
	add_child(frame)

	var panel := VBoxContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = PANEL_SIZE
	panel.size = PANEL_SIZE
	panel.offset_left = -PANEL_SIZE.x * 0.5
	panel.offset_top = -PANEL_SIZE.y * 0.5
	panel.offset_right = PANEL_SIZE.x * 0.5
	panel.offset_bottom = PANEL_SIZE.y * 0.5
	panel.add_theme_constant_override("separation", 5)
	add_child(panel)

	var title_label := Label.new()
	title_label.text = "Seleccion de Jefe"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", TITLE_FONT_SIZE)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(title_label)

	boss_label = Label.new()
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_label.add_theme_font_size_override("font_size", BOSS_FONT_SIZE)
	boss_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(boss_label)

	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", SMALL_FONT_SIZE)
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(status_label)

	var nav := HBoxContainer.new()
	nav.alignment = BoxContainer.ALIGNMENT_CENTER
	nav.add_theme_constant_override("separation", 8)
	panel.add_child(nav)

	previous_button = Button.new()
	previous_button.text = "<"
	previous_button.custom_minimum_size = Vector2(38, 28)
	previous_button.add_theme_font_size_override("font_size", BUTTON_FONT_SIZE)
	previous_button.pressed.connect(_on_previous_pressed)
	nav.add_child(previous_button)

	start_button = Button.new()
	start_button.custom_minimum_size = Vector2(94, 28)
	start_button.add_theme_font_size_override("font_size", BUTTON_FONT_SIZE)
	start_button.pressed.connect(_on_start_pressed)
	nav.add_child(start_button)

	next_button = Button.new()
	next_button.text = ">"
	next_button.custom_minimum_size = Vector2(38, 28)
	next_button.add_theme_font_size_override("font_size", BUTTON_FONT_SIZE)
	next_button.pressed.connect(_on_next_pressed)
	nav.add_child(next_button)

	var difficulty_row := HBoxContainer.new()
	difficulty_row.alignment = BoxContainer.ALIGNMENT_CENTER
	difficulty_row.add_theme_constant_override("separation", 6)
	panel.add_child(difficulty_row)

	for difficulty in ["easy", "medium", "hard"]:
		var button := Button.new()
		button.custom_minimum_size = Vector2(68, 24)
		button.add_theme_font_size_override("font_size", SMALL_FONT_SIZE)
		button.pressed.connect(_on_difficulty_pressed.bind(difficulty))
		difficulty_buttons[difficulty] = button
		difficulty_row.add_child(button)

	detail_label = Label.new()
	detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.add_theme_font_size_override("font_size", SMALL_FONT_SIZE)
	detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(detail_label)

func _on_previous_pressed() -> void:
	AudioManager.play_ui_select()
	boss_index = max(0, boss_index - 1)
	GameState.select_boss(boss_index)
	_refresh()

func _on_next_pressed() -> void:
	AudioManager.play_ui_select()
	boss_index = min(GameState.get_boss_count() - 1, boss_index + 1)
	GameState.select_boss(boss_index)
	_refresh()

func _on_difficulty_pressed(difficulty: String) -> void:
	AudioManager.play_ui_select()
	GameState.set_difficulty(difficulty)
	_refresh()

func _on_start_pressed() -> void:
	if not GameState.can_start_selected_boss():
		return
	AudioManager.play_ui_select()
	get_tree().change_scene_to_file(GameState.get_selected_boss_scene_path())

func _refresh() -> void:
	var boss := GameState.get_boss_data(boss_index)
	var difficulty := GameState.get_selected_difficulty_data()
	var unlocked := GameState.is_boss_unlocked(boss_index)
	var playable := GameState.can_start_selected_boss()

	boss_label.text = "%d. %s" % [boss_index + 1, boss["name"]]
	status_label.text = "%s - %s" % [boss["status"], "Desbloqueado" if unlocked else "Bloqueado"]
	detail_label.text = "Dificultad %s: %s. Jefe listo para probar en arena." % [difficulty["label"], difficulty["description"]]

	previous_button.disabled = boss_index == 0
	next_button.disabled = boss_index >= GameState.get_boss_count() - 1
	start_button.disabled = not playable
	start_button.text = "Iniciar" if playable else "No disponible"

	for key in difficulty_buttons.keys():
		var button: Button = difficulty_buttons[key]
		button.text = GameState.DIFFICULTIES[key]["label"]
		button.disabled = key == GameState.selected_difficulty
