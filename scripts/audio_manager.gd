extends Node

var sound_enabled: bool = true
var music_enabled: bool = true
var lobby_music_enabled: bool = true
var game_music_enabled: bool = true
var pickup_enabled: bool = true
var danger_enabled: bool = true
var win_enabled: bool = true
var game_over_enabled: bool = true

@onready var lobby_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var game_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var pickup_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var danger_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var win_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var game_over_player: AudioStreamPlayer = AudioStreamPlayer.new()

const LOBBY_MUSIC_PATHS := [
	"res://audio/start.mp3",
	"res://audio/Start.mp3",
	"res://audio/start.wav"
]
const GAME_MUSIC_PATHS := [
	"res://audio/gamesound.mp3",
	"res://audio/game_sound.mp3",
	"res://audio/game_music.mp3"
]
const PICKUP_SFX_PATHS := [
	"res://audio/food.mp3",
	"res://audio/pickup.mp3",
	"res://audio/gameplay.wav"
]
const WIN_SFX_PATHS := [
	"res://audio/win.mp3",
	"res://audio/win.wav"
]
const DANGER_SFX_PATHS := [
	"res://audio/danger.wav",
	"res://audio/hit.wav"
]
const GAME_OVER_SFX_PATHS := [
	"res://audio/game over.mp3",
	"res://audio/game_over.mp3",
	"res://audio/gameover.mp3",
	"res://audio/end.wav"
]

func _ready() -> void:
	add_child(lobby_player)
	add_child(game_player)
	add_child(pickup_player)
	add_child(danger_player)
	add_child(win_player)
	add_child(game_over_player)
	lobby_player.stream = _load_first_existing(LOBBY_MUSIC_PATHS)
	game_player.stream = _load_first_existing(GAME_MUSIC_PATHS)
	pickup_player.stream = _load_first_existing(PICKUP_SFX_PATHS)
	danger_player.stream = _load_first_existing(DANGER_SFX_PATHS)
	win_player.stream = _load_first_existing(WIN_SFX_PATHS)
	game_over_player.stream = _load_first_existing(GAME_OVER_SFX_PATHS)
	lobby_player.volume_db = -8.0
	game_player.volume_db = -9.0
	lobby_player.finished.connect(func() -> void: _restart_loop(lobby_player))
	game_player.finished.connect(func() -> void: _restart_loop(game_player))
	_log_missing_streams()

func play_lobby_loop() -> void:
	if not music_enabled or not lobby_music_enabled:
		return
	if game_player.playing:
		game_player.stop()
	if lobby_player.stream and not lobby_player.playing:
		lobby_player.play()

func stop_lobby_loop() -> void:
	if lobby_player.playing:
		lobby_player.stop()

func play_game_loop() -> void:
	if not music_enabled or not game_music_enabled:
		return
	if lobby_player.playing:
		lobby_player.stop()
	if game_player.stream and not game_player.playing:
		game_player.play()

func stop_game_loop() -> void:
	if game_player.playing:
		game_player.stop()

func play_gameplay_pickup() -> void:
	if not pickup_enabled:
		return
	_play_if_exists(pickup_player)

func play_danger() -> void:
	if not danger_enabled:
		return
	_play_if_exists(danger_player)

func play_win() -> void:
	if not win_enabled:
		return
	_play_if_exists(win_player)

func play_game_over() -> void:
	if not game_over_enabled:
		return
	_play_if_exists(game_over_player)

func _load_first_existing(paths: Array) -> AudioStream:
	for path in paths:
		if ResourceLoader.exists(path):
			return load(path)
	return null

func _play_if_exists(player: AudioStreamPlayer) -> void:
	if not sound_enabled:
		return
	if player.stream:
		if player.playing:
			player.stop()
		player.play()

func _restart_loop(player: AudioStreamPlayer) -> void:
	if music_enabled and player.stream:
		player.play()

func _log_missing_streams() -> void:
	if not lobby_player.stream:
		push_warning("AudioManager: lobby music (start.mp3) not found in res://audio/")
	if not game_player.stream:
		push_warning("AudioManager: game music (gamesound.mp3) not found in res://audio/")
	if not pickup_player.stream:
		push_warning("AudioManager: collectible sound not found in res://audio/")
	if not danger_player.stream:
		push_warning("AudioManager: danger sound not found in res://audio/")
	if not win_player.stream:
		push_warning("AudioManager: win sound not found in res://audio/")
	if not game_over_player.stream:
		push_warning("AudioManager: game over sound not found in res://audio/")
