extends Node2D

const COLLECTIBLE_SCENE := preload("res://scenes/entities/collectible.tscn")
const ENEMY_SCENE := preload("res://scenes/entities/enemy.tscn")

var score_in_level: int = 0
var time_left: int = 0
var level_data: Dictionary

@onready var ui_score: Label = $CanvasLayer/UI/ScoreLabel
@onready var ui_attempts: Label = $CanvasLayer/UI/AttemptsLabel
@onready var ui_timer: Label = $CanvasLayer/UI/TimerLabel
@onready var ui_level: Label = $CanvasLayer/UI/LevelLabel
@onready var countdown: Timer = $CountdownTimer
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	randomize()
	player.add_to_group("player")
	level_data = GameState.active_level_data()
	time_left = int(level_data.time)
	ui_level.text = str(level_data.name)
	_update_ui()
	_spawn_collectibles(int(level_data.collectibles))
	_spawn_enemies(int(level_data.enemies), float(level_data.enemy_speed))
	countdown.timeout.connect(_on_countdown_timeout)
	countdown.start()

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
	score_in_level += points
	GameState.add_score(points)
	AudioManager.play_gameplay_pickup()
	_update_ui()
	if $Collectibles.get_child_count() == 0:
		_finish_level()

func _on_player_hit() -> void:
	GameState.lose_attempt()
	if GameState.attempts_left <= 0:
		AudioManager.play_end()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return
	get_tree().reload_current_scene()

func _on_countdown_timeout() -> void:
	time_left -= 1
	_update_ui()
	if time_left <= 0:
		_finish_level()

func _finish_level() -> void:
	countdown.stop()
	var target: int = int(level_data.target)
	var passed := score_in_level >= target
	if passed:
		GameState.register_level_win()
	AudioManager.play_end()
	var result_scene: PackedScene = preload("res://scenes/results.tscn")
	var result_instance: Control = result_scene.instantiate()
	result_instance.set_meta("passed", passed)
	result_instance.set_meta("level_score", score_in_level)
	result_instance.set_meta("target", target)
	get_tree().root.add_child(result_instance)
	queue_free()

func _update_ui() -> void:
	ui_score.text = "نقاط المستوى: %d" % score_in_level
	ui_attempts.text = "المحاولات المتبقية: %d" % GameState.attempts_left
	ui_timer.text = "الوقت المتبقي: %d" % time_left
