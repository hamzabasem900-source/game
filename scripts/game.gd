extends Node2D

const COLLECTIBLE_SCENE := preload("res://scenes/entities/collectible.tscn")
const ENEMY_SCENE := preload("res://scenes/entities/enemy.tscn")
const RESPAWN_COLLECTIBLES := 6
const BACKGROUND_THEMES := [
	{"base": Color(0.06, 0.08, 0.13, 1), "glow_1": Color(0.18, 0.45, 0.86, 0.25), "glow_2": Color(0.13, 0.62, 0.4, 0.22), "grid": Color(1, 1, 1, 0.05)},
	{"base": Color(0.11, 0.06, 0.14, 1), "glow_1": Color(0.67, 0.27, 0.86, 0.24), "glow_2": Color(0.19, 0.66, 0.83, 0.22), "grid": Color(1, 0.9, 1, 0.06)},
	{"base": Color(0.05, 0.12, 0.10, 1), "glow_1": Color(0.11, 0.73, 0.52, 0.24), "glow_2": Color(0.99, 0.68, 0.24, 0.20), "grid": Color(0.9, 1, 0.92, 0.05)}
]

var score_in_level: int = 0
var time_left: int = 0
var level_data: Dictionary
var level_finished: bool = false
var is_paused: bool = false
var background_theme_index: int = 0

@onready var ui_score: Label = $CanvasLayer/UI/ScoreLabel
@onready var ui_attempts: Label = $CanvasLayer/UI/AttemptsLabel
@onready var ui_timer: Label = $CanvasLayer/UI/TimerLabel
@onready var ui_level: Label = $CanvasLayer/UI/LevelLabel
@onready var countdown: Timer = $CountdownTimer
@onready var player: CharacterBody2D = $Player
@onready var bg_base: ColorRect = $Background/Base
@onready var bg_glow_1: Polygon2D = $Background/Glow1
@onready var bg_glow_2: Polygon2D = $Background/Glow2
@onready var bg_grid: Polygon2D = $Background/GridHint

func _ready() -> void:
	randomize()
	player.add_to_group("player")
	level_data = GameState.active_level_data()
	AudioManager.play_game_loop()
	$CanvasLayer.process_mode = Node.PROCESS_MODE_ALWAYS
	$CanvasLayer/PauseMenu.process_mode = Node.PROCESS_MODE_ALWAYS
	time_left = int(level_data.time)
	ui_level.text = "%s | %s" % [str(level_data.name), str(level_data.difficulty)]
	_update_ui()
	_spawn_collectibles(int(level_data.collectibles))
	_spawn_enemies(int(level_data.enemies), float(level_data.enemy_speed))
	countdown.timeout.connect(_on_countdown_timeout)
	$CanvasLayer/PauseButton.pressed.connect(_toggle_pause_menu)
	$CanvasLayer/PauseMenu/ResumeButton.pressed.connect(_resume_game)
	$CanvasLayer/PauseMenu/MapButton.pressed.connect(_go_to_map)
	$CanvasLayer/PauseMenu/LobbyButton.pressed.connect(_go_to_lobby)
	countdown.start()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause_menu()

func _spawn_collectibles(amount: int) -> void:
	for i in amount:
		var collectible: Area2D = COLLECTIBLE_SCENE.instantiate()
		collectible.global_position = _random_play_position()
		collectible.collected.connect(_on_collectible_collected)
		$Collectibles.add_child(collectible)

func _spawn_enemies(amount: int, speed: float) -> void:
	for i in amount:
		var enemy: Area2D = ENEMY_SCENE.instantiate()
		enemy.global_position = _random_play_position()
		enemy.speed = speed + randf_range(-20.0, 30.0)
		enemy.player_hit.connect(_on_player_hit)
		$Enemies.add_child(enemy)

func _random_play_position() -> Vector2:
	var viewport_rect := get_viewport_rect().size
	return Vector2(randf_range(80.0, viewport_rect.x - 80.0), randf_range(120.0, viewport_rect.y - 80.0))

func _on_collectible_collected(points: int) -> void:
	if level_finished:
		return
	score_in_level += points
	AudioManager.play_gameplay_pickup()
	_update_ui()
	var target: int = int(level_data.target)
	if score_in_level >= target:
		_show_results(true, false, target)
		return
		# العنصر الحالي لم يحذف بعد في نفس الاطار، لذلك نتحقق من <= 1
	if $Collectibles.get_child_count() <= 1:
		_spawn_collectibles(RESPAWN_COLLECTIBLES)
		_advance_background_theme()

func _on_player_hit() -> void:
	if level_finished:
		return
	AudioManager.play_danger()
	GameState.lose_attempt()
	if GameState.attempts_left <= 0:
		_show_results(false, true)
		return
	get_tree().reload_current_scene()

func _on_countdown_timeout() -> void:
	if level_finished:
		return
	time_left -= 1
	_update_ui()
	if time_left <= 0:
		_finish_level()

func _finish_level() -> void:
	var target: int = int(level_data.target)
	var passed := score_in_level >= target
	_show_results(passed, false, target)

func _show_results(passed: bool, game_over: bool, target: int = -1) -> void:
	if level_finished:
		return
	level_finished = true
	_set_paused(false)
	countdown.stop()
	if passed:
		GameState.add_score(score_in_level)
		GameState.register_level_win()
	AudioManager.stop_game_loop()
	if passed:
		AudioManager.play_win()
		GameState.store_result(true, false, score_in_level, target if target >= 0 else int(level_data.target))
		get_tree().change_scene_to_file("res://scenes/results.tscn")
	else:
		AudioManager.play_game_over()
		GameState.store_result(false, true, score_in_level, target if target >= 0 else int(level_data.target))
		get_tree().change_scene_to_file("res://scenes/results.tscn")

func _update_ui() -> void:
	ui_score.text = "💰 النقاط: %d / %d" % [score_in_level, int(level_data.target)]
	ui_attempts.text = "❤️ الأرواح: %d" % GameState.attempts_left
	ui_timer.text = "⏱️ الوقت: %d" % time_left

func _toggle_pause_menu() -> void:
	if level_finished:
		return
	_set_paused(not is_paused)

func _resume_game() -> void:
	_set_paused(false)

func _go_to_map() -> void:
	_set_paused(false)
	AudioManager.stop_game_loop()
	get_tree().change_scene_to_file("res://scenes/interactive_map.tscn")

func _go_to_lobby() -> void:
	_set_paused(false)
	AudioManager.stop_game_loop()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _set_paused(value: bool) -> void:
	is_paused = value
	get_tree().paused = value
	$CanvasLayer/PauseMenu.visible = value

func _advance_background_theme() -> void:
	background_theme_index = (background_theme_index + 1) % BACKGROUND_THEMES.size()
	var theme: Dictionary = BACKGROUND_THEMES[background_theme_index]
	bg_base.color = theme["base"]
	bg_glow_1.color = theme["glow_1"]
	bg_glow_2.color = theme["glow_2"]
	bg_grid.color = theme["grid"]
