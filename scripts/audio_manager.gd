extends Node

@onready var start_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var gameplay_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var end_player: AudioStreamPlayer = AudioStreamPlayer.new()

const START_SFX := "res://audio/start.wav"
const GAMEPLAY_SFX := "res://audio/gameplay.wav"
const END_SFX := "res://audio/end.wav"

func _ready() -> void:
	add_child(start_player)
	add_child(gameplay_player)
	add_child(end_player)
	_try_load_stream(start_player, START_SFX)
	_try_load_stream(gameplay_player, GAMEPLAY_SFX)
	_try_load_stream(end_player, END_SFX)
	_apply_volume()

func _apply_volume() -> void:
	var db := linear_to_db(clamp(GameState.master_volume, 0.001, 1.0))
	start_player.volume_db = db
	gameplay_player.volume_db = db
	end_player.volume_db = db

func play_start() -> void:
	_apply_volume()
	if GameState.sfx_enabled:
		_play_if_exists(start_player)

func play_gameplay_pickup() -> void:
	_apply_volume()
	if GameState.sfx_enabled:
		_play_if_exists(gameplay_player)

func play_end() -> void:
	_apply_volume()
	if GameState.sfx_enabled:
		_play_if_exists(end_player)

func _try_load_stream(player: AudioStreamPlayer, path: String) -> void:
	if ResourceLoader.exists(path):
		player.stream = load(path)

func _play_if_exists(player: AudioStreamPlayer) -> void:
	if player.stream:
		player.play()
