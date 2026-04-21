extends Node

const LEVELS := [
	{"name": "المستوى 1", "time": 70, "target": 120, "collectibles": 14, "enemies": 2, "enemy_speed": 90.0, "difficulty": "سهل"},
	{"name": "المستوى 2", "time": 55, "target": 170, "collectibles": 16, "enemies": 3, "enemy_speed": 120.0, "difficulty": "متوسط"},
	{"name": "المستوى 3", "time": 40, "target": 220, "collectibles": 18, "enemies": 4, "enemy_speed": 150.0, "difficulty": "صعب"},
	{"name": "المستوى 4", "time": 30, "target": 280, "collectibles": 20, "enemies": 5, "enemy_speed": 180.0, "difficulty": "شديد"}
]

const MAX_ATTEMPTS := 5

var total_score: int = 0
var attempts_left: int = MAX_ATTEMPTS
var unlocked_level: int = 0
var current_level: int = 0
var levels_won: int = 0

func reset_run() -> void:
	total_score = 0
	attempts_left = MAX_ATTEMPTS
	unlocked_level = 0
	levels_won = 0
	current_level = 0

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
