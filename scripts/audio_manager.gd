extends Node

@onready var start_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var gameplay_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var win_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var game_over_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var bgm_player: AudioStreamPlayer = AudioStreamPlayer.new()

const START_SFX_PATHS := [
	"res://audio/start.mp3",
	"res://audio/Start.mp3",
	"res://audio/start.wav"
]
const GAMEPLAY_SFX_PATHS := [
	"res://audio/food.mp3",
	"res://audio/pickup.mp3",
	"res://audio/gameplay.wav"
]
const WIN_SFX_PATHS := [
	"res://audio/win.mp3",
	"res://audio/win.wav"
]
const GAME_OVER_SFX_PATHS := [
	"res://audio/game over.mp3",
	"res://audio/game_over.mp3",
	"res://audio/end.wav"
]
const BGM_PATHS := [
	"res://audio/gamesound.mp3",
	"res://audio/game_sound.mp3",
	"res://audio/game_music.mp3"
]

func _ready() -> void:
	add_child(start_player)
	add_child(gameplay_player)
	add_child(win_player)
	add_child(game_over_player)
	add_child(bgm_player)
	bgm_player.volume_db = -8.0
	bgm_player.stream = _load_first_existing(BGM_PATHS)
	bgm_player.autoplay = false
	bgm_player.finished.connect(func() -> void:
		if bgm_player.stream:
			bgm_player.play()
	)
	start_player.stream = _load_first_existing(START_SFX_PATHS)
	gameplay_player.stream = _load_first_existing(GAMEPLAY_SFX_PATHS)
	win_player.stream = _load_first_existing(WIN_SFX_PATHS)
	game_over_player.stream = _load_first_existing(GAME_OVER_SFX_PATHS)
	_log_missing_streams()

func play_start() -> void:
	_play_if_exists(start_player)

func play_gameplay_pickup() -> void:
	_play_if_exists(gameplay_player)

func play_win() -> void:
	_play_if_exists(win_player)

func play_game_over() -> void:
	_play_if_exists(game_over_player)

func play_background() -> void:
	if bgm_player.stream and not bgm_player.playing:
		bgm_player.play()

func stop_background() -> void:
	if bgm_player.playing:
		bgm_player.stop()

func _load_first_existing(paths: Array) -> AudioStream:
	for path in paths:
		if ResourceLoader.exists(path):
			return load(path)
	return null

func _play_if_exists(player: AudioStreamPlayer) -> void:
	if player.stream:
		if player.playing:
			player.stop()
		player.play()

func _log_missing_streams() -> void:
	if not start_player.stream:
		push_warning("AudioManager: start sound not found in res://audio/")
	if not gameplay_player.stream:
		push_warning("AudioManager: collectible sound not found in res://audio/")
	if not win_player.stream:
		push_warning("AudioManager: win sound not found in res://audio/")
	if not game_over_player.stream:
		push_warning("AudioManager: game over sound not found in res://audio/")
	if not bgm_player.stream:
		push_warning("AudioManager: background music not found in res://audio/")
