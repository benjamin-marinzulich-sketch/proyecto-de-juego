extends Node

const MUSIC_BATTLE := preload("res://assets/audio/music_battle.wav")
const SFX_ATTACK := preload("res://assets/audio/attack.wav")
const SFX_HIT := preload("res://assets/audio/hit.wav")
const SFX_UI_SELECT := preload("res://assets/audio/ui_select.wav")

var _music_player: AudioStreamPlayer

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.volume_db = -14.0
	add_child(_music_player)
	play_battle_music()

func play_battle_music() -> void:
	if _music_player.playing:
		return
	_music_player.stream = MUSIC_BATTLE
	if _music_player.stream is AudioStreamWAV:
		_music_player.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	_music_player.play()

func play_attack() -> void:
	play_sfx(SFX_ATTACK, -8.0)

func play_hit() -> void:
	play_sfx(SFX_HIT, -6.0)

func play_ui_select() -> void:
	play_sfx(SFX_UI_SELECT, -10.0)

func play_sfx(stream: AudioStream, volume_db := -8.0) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
