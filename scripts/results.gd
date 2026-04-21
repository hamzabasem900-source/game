extends Control

func _ready() -> void:
	var passed: bool = bool(get_meta("passed", false))
	var level_score: int = int(get_meta("level_score", 0))
	var target: int = int(get_meta("target", 0))
	
	if passed:
		$Panel/VBoxContainer/TitleLabel.text = "نجاح!"
		$Panel/VBoxContainer/MessageLabel.text = "أحرزت %d نقطة (الهدف: %d)." % [level_score, target]
	else:
		$Panel/VBoxContainer/TitleLabel.text = "انتهى الوقت"
		$Panel/VBoxContainer/MessageLabel.text = "النقاط %d أقل من الهدف %d." % [level_score, target]

	$Panel/VBoxContainer/TotalLabel.text = "إجمالي نقاطك: %d" % GameState.total_score
	$Panel/VBoxContainer/AttemptsLabel.text = "المحاولات المتبقية: %d" % GameState.attempts_left
	$Panel/VBoxContainer/MapButton.pressed.connect(_on_map_pressed)
	$Panel/VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)

func _on_map_pressed() -> void:
	if GameState.run_completed():
		GameState.reset_run()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return
	get_tree().change_scene_to_file("res://scenes/map.tscn")

func _on_menu_pressed() -> void:
	GameState.reset_run()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
