extends Control

const PANEL_SIZE := Vector2(270, 150)
const TITLE_FONT_SIZE := 14
const DETAIL_FONT_SIZE := 8
const BUTTON_FONT_SIZE := 7

func _ready() -> void:
	_build_interface()

func _build_interface() -> void:
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
	panel.add_theme_constant_override("separation", 8)
	add_child(panel)

	var title := Label.new()
	title.text = GameState.last_result_title
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", TITLE_FONT_SIZE)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(title)

	var detail := Label.new()
	detail.text = GameState.last_result_detail
	detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_theme_font_size_override("font_size", DETAIL_FONT_SIZE)
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(detail)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 8)
	panel.add_child(button_row)

	var retry_button := Button.new()
	retry_button.text = "Reintentar"
	retry_button.custom_minimum_size = Vector2(86, 28)
	retry_button.add_theme_font_size_override("font_size", BUTTON_FONT_SIZE)
	retry_button.pressed.connect(_on_retry_pressed)
	button_row.add_child(retry_button)

	var selector_button := Button.new()
	selector_button.text = "Selector"
	selector_button.custom_minimum_size = Vector2(86, 28)
	selector_button.add_theme_font_size_override("font_size", BUTTON_FONT_SIZE)
	selector_button.pressed.connect(_on_selector_pressed)
	button_row.add_child(selector_button)

func _on_retry_pressed() -> void:
	var path := GameState.get_selected_boss_scene_path()
	if path == "":
		_on_selector_pressed()
		return
	AudioManager.play_ui_select()
	get_tree().change_scene_to_file(path)

func _on_selector_pressed() -> void:
	AudioManager.play_ui_select()
	get_tree().change_scene_to_file("res://scenas/ui/selector/SelectorNiveles.tscn")
