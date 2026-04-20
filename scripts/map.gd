extends Control

func _ready() -> void:
	$Panel/VBoxContainer/Level1.pressed.connect(func() -> void: _start_level(0))
	$Panel/VBoxContainer/Level2.pressed.connect(func() -> void: _start_level(1))
	$Panel/VBoxContainer/Level3.pressed.connect(func() -> void: _start_level(2))
	$Panel/VBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	_refresh_buttons()

func _refresh_buttons() -> void:
	$Panel/VBoxContainer/Level2.disabled = GameState.unlocked_level < 1
	$Panel/VBoxContainer/Level3.disabled = GameState.unlocked_level < 2
	$Panel/VBoxContainer/StatusLabel.text = "النقاط الحالية: %d | المحاولات: %d" % [GameState.total_score, GameState.attempts_left]

func _start_level(level_index: int) -> void:
	GameState.begin_level(level_index)
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
