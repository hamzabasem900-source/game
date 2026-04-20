extends Node2D

const COLLECTIBLE_SCENE := preload("res://scenes/entities/collectible.tscn")
const ENEMY_SCENE := preload("res://scenes/entities/enemy.tscn")

var score_in_level: int = 0
var time_left: int = 0
var level_data: Dictionary
var level_ended: bool = false

@onready var ui_score: Label = $CanvasLayer/UI/TopRow/ScoreLabel
@onready var ui_attempts: Label = $CanvasLayer/UI/TopRow/AttemptsLabel
@onready var ui_timer: Label = $CanvasLayer/UI/TopRow/TimerLabel
@onready var ui_level: Label = $CanvasLayer/UI/TopRow/LevelLabel
@onready var ui_progress: ProgressBar = $CanvasLayer/UI/TopRow/TimeProgress
@onready var countdown: Timer = $CountdownTimer
@onready var player: CharacterBody2D = $Player
@onready var spawn_timer: Timer = $EnemySpawnTimer

func _ready() -> void:
	randomize()
	_apply_background("game_bg")
	player.add_to_group("player")
	level_data = GameState.active_level_data()
	time_left = int(level_data.time)
	ui_level.text = GameState.level_name(level_data)
	ui_progress.max_value = time_left
	ui_progress.value = time_left
	_update_ui()
	_spawn_collectibles(int(level_data.collectibles))
	_spawn_enemies(int(level_data.enemies), float(level_data.enemy_speed))
	countdown.timeout.connect(_on_countdown_timeout)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	countdown.start()
	spawn_timer.start()

func _spawn_collectibles(amount: int) -> void:
	for i in amount:
		var collectible: Area2D = COLLECTIBLE_SCENE.instantiate()
		collectible.global_position = _random_play_position()
		collectible.collected.connect(_on_collectible_collected)
		$Collectibles.add_child(collectible)

func _spawn_enemies(amount: int, speed: float) -> void:
	for i in amount:
		_spawn_single_enemy(speed + randf_range(-15.0, 35.0))

func _spawn_single_enemy(speed: float) -> void:
	var enemy: Area2D = ENEMY_SCENE.instantiate()
	enemy.global_position = _random_play_position()
	enemy.speed = speed
	enemy.chase_weight = randf_range(0.75, 1.25)
	enemy.player_hit.connect(_on_player_hit)
	enemy.set_target(player)
	$Enemies.add_child(enemy)

func _random_play_position() -> Vector2:
	var viewport_size := get_viewport_rect().size
	return Vector2(randf_range(80.0, viewport_size.x - 80.0), randf_range(140.0, viewport_size.y - 80.0))

func _on_collectible_collected(points: int) -> void:
	if level_ended:
		return
	score_in_level += points
	GameState.add_score(points)
	AudioManager.play_gameplay_pickup()
	_update_ui()
	if $Collectibles.get_child_count() == 0:
		_finish_level(true, "جمعت كل العناصر! ممتاز")

func _on_player_hit() -> void:
	if level_ended:
		return
	GameState.lose_attempt()
	if GameState.attempts_left <= 0:
		_finish_level(false, "انتهت كل المحاولات")
		return
	player.global_position = Vector2(640, 360)
	_update_ui()

func _on_countdown_timeout() -> void:
	if level_ended:
		return
	time_left -= 1
	ui_progress.value = max(time_left, 0)
	_update_ui()
	if time_left <= 0:
		var target: int = int(level_data.target)
		if score_in_level >= target:
			_finish_level(true, "حققت الهدف قبل انتهاء الوقت")
		else:
			GameState.lose_attempt()
			if GameState.attempts_left <= 0:
				_finish_level(false, "انتهى الوقت وانتهت المحاولات")
			else:
				_finish_level(false, "انتهى الوقت ولم تحقق الهدف")

func _on_spawn_timer_timeout() -> void:
	if level_ended:
		return
	if $Enemies.get_child_count() < int(level_data.enemies) + 3:
		_spawn_single_enemy(float(level_data.enemy_speed) + randf_range(20.0, 55.0))

func _finish_level(passed: bool, message: String) -> void:
	if level_ended:
		return
	level_ended = true
	countdown.stop()
	spawn_timer.stop()
	var target: int = int(level_data.target)

	if passed:
		GameState.register_level_win()
		if GameState.run_completed():
			GameState.set_result("final_win", "فــوز! أنهيت كل المستويات", score_in_level, target)
		else:
			GameState.set_result("win_level", message, score_in_level, target)
	else:
		if GameState.attempts_left <= 0:
			GameState.set_result("game_over", message, score_in_level, target)
		else:
			GameState.set_result("lose_level", message, score_in_level, target)

	AudioManager.play_end()
	get_tree().change_scene_to_file("res://scenes/results.tscn")

func _update_ui() -> void:
	ui_score.text = "نقاط المستوى: %d" % score_in_level
	ui_attempts.text = "محاولات: %d" % GameState.attempts_left
	ui_timer.text = "الوقت: %d" % time_left

func _apply_background(name_no_ext: String) -> void:
	var path := "res://user_assets/backgrounds/%s.png" % name_no_ext
	if ResourceLoader.exists(path):
		$Background.texture = load(path)
