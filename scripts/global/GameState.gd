extends Node

signal difficulty_changed(difficulty: String)
signal progress_changed

const DIFFICULTIES := {
	"easy": {
		"label": "Facil",
		"phase_count": 1,
		"description": "1 fase por jefe"
	},
	"medium": {
		"label": "Media",
		"phase_count": 2,
		"description": "2 fases por jefe"
	},
	"hard": {
		"label": "Dificil",
		"phase_count": 3,
		"description": "3 fases por jefe"
	}
}

const BOSSES := [
	{
		"id": "luxy_junior",
		"name": "Luxy Junior",
		"scene_path": "res://scenas/levels/Tutorial.tscn",
		"boss_scene_path": "res://scenas/bosses/luxo jr.tscn",
		"status": "Listo"
	},
	{
		"id": "boss_2",
		"name": "Rata Callejera",
		"scene_path": "res://scenas/levels/Tutorial.tscn",
		"boss_scene_path": "res://scenas/bosses/rat_boss_2.tscn",
		"status": "Prueba"
	},
	{
		"id": "boss_3",
		"name": "Rata Alfa",
		"scene_path": "res://scenas/levels/Tutorial.tscn",
		"boss_scene_path": "res://scenas/bosses/rat_boss_3.tscn",
		"status": "Prueba"
	}
]

var selected_difficulty := "easy"
var selected_boss_index := 0
var unlocked_bosses := BOSSES.size()
var last_result := ""
var last_result_title := ""
var last_result_detail := ""

func set_difficulty(difficulty: String) -> void:
	if not DIFFICULTIES.has(difficulty):
		return
	selected_difficulty = difficulty
	difficulty_changed.emit(selected_difficulty)

func get_selected_difficulty_data() -> Dictionary:
	return DIFFICULTIES[selected_difficulty]

func get_phase_count() -> int:
	return int(get_selected_difficulty_data()["phase_count"])

func get_boss_count() -> int:
	return BOSSES.size()

func get_boss_data(index: int) -> Dictionary:
	return BOSSES[clamp(index, 0, BOSSES.size() - 1)]

func is_boss_unlocked(index: int) -> bool:
	return index < unlocked_bosses

func select_boss(index: int) -> void:
	selected_boss_index = clamp(index, 0, BOSSES.size() - 1)

func can_start_selected_boss() -> bool:
	var boss := get_boss_data(selected_boss_index)
	return is_boss_unlocked(selected_boss_index) and String(boss["scene_path"]) != ""

func get_selected_boss_scene_path() -> String:
	return String(get_boss_data(selected_boss_index)["scene_path"])

func get_selected_boss_actor_scene_path() -> String:
	return String(get_boss_data(selected_boss_index)["boss_scene_path"])

func get_selected_boss_name() -> String:
	return String(get_boss_data(selected_boss_index)["name"])

func complete_selected_boss() -> void:
	if selected_boss_index + 1 >= unlocked_bosses:
		unlocked_bosses = min(unlocked_bosses + 1, BOSSES.size())
	progress_changed.emit()

func set_battle_result(result: String, title: String, detail: String) -> void:
	last_result = result
	last_result_title = title
	last_result_detail = detail
