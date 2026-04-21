extends Node

const LEVELS := [
	{"name": "المستوى 1", "time": 50, "target": 200, "collectibles": 14, "enemies": 2, "enemy_speed": 95.0, "difficulty": "سهل"},
	{"name": "المستوى 2", "time": 42, "target": 260, "collectibles": 18, "enemies": 4, "enemy_speed": 140.0, "difficulty": "متوسط+"},
	{"name": "المستوى 3", "time": 35, "target": 340, "collectibles": 22, "enemies": 6, "enemy_speed": 180.0, "difficulty": "صعب جدًا"}
]

const MAX_ATTEMPTS := 3

var total_score: int = 0
var attempts_left: int = MAX_ATTEMPTS
var unlocked_level: int = 0
var current_level: int = 0
var levels_won: int = 0
var last_result: Dictionary = {}

func reset_run() -> void:
	total_score = 0
	attempts_left = MAX_ATTEMPTS
	unlocked_level = 0
	levels_won = 0
	current_level = 0
	last_result.clear()

func begin_level(level_index: int) -> void:
	current_level = clamp(level_index, 0, LEVELS.size() - 1)

func active_level_data() -> Dictionary:
	return LEVELS[current_level]

func add_score(points: int) -> void:
	total_score += points

func lose_attempt() -> void:
	attempts_left = max(0, attempts_left - 1)

func register_level_win() -> void:
	levels_won += 1
	if current_level < LEVELS.size() - 1:
		unlocked_level = max(unlocked_level, current_level + 1)

func run_completed() -> bool:
	return levels_won >= LEVELS.size()

func store_result(passed: bool, game_over: bool, level_score: int, target: int) -> void:
	last_result = {
		"passed": passed,
		"game_over": game_over,
		"level_score": level_score,
		"target": target
	}
