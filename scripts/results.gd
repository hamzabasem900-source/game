extends Control

func _ready() -> void:
	var result_data := GameState.last_result
	var passed: bool = bool(result_data.get("passed", false))
	var game_over: bool = bool(result_data.get("game_over", false))
	var level_score: int = int(result_data.get("level_score", 0))
	var target: int = int(result_data.get("target", 0))
	
	if game_over:
		AudioManager.stop_lobby_loop()
	else:
		AudioManager.play_lobby_loop()
	
	if game_over:
		$Panel/VBoxContainer/TitleLabel.text = "💀 GAME OVER"
		$Panel/VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		$Panel/VBoxContainer/MessageLabel.text = "انتهت الأرواح. نقاط هذا المستوى: %d." % level_score
		$Panel/VBoxContainer/MapButton.text = "العودة إلى الخريطة"
	elif passed:
		$Panel/VBoxContainer/TitleLabel.text = "🏆 YOU WIN"
		$Panel/VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color(0.25, 1.0, 0.45))
		$Panel/VBoxContainer/MessageLabel.text = "أحرزت %d نقطة (الهدف: %d)." % [level_score, target]
		$Panel/VBoxContainer/MapButton.text = "المستوى التالي / الخريطة"
	else:
		$Panel/VBoxContainer/TitleLabel.text = "💀 GAME OVER"
		$Panel/VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		$Panel/VBoxContainer/MessageLabel.text = "النقاط %d أقل من الهدف %d." % [level_score, target]
		$Panel/VBoxContainer/MapButton.text = "إعادة المحاولة من الخريطة"

	$Panel/VBoxContainer/TotalLabel.text = "💰 إجمالي النقاط (بعد الانتصارات): %d" % GameState.total_score
	$Panel/VBoxContainer/AttemptsLabel.text = "❤️ الأرواح المتبقية: %d" % GameState.attempts_left
	$Panel/VBoxContainer/MapButton.pressed.connect(_on_map_pressed)
	$Panel/VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)

func _on_map_pressed() -> void:
	var game_over: bool = bool(GameState.last_result.get("game_over", false))
	if game_over:
		GameState.restore_attempts()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return
	if GameState.run_completed():
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return
	get_tree().change_scene_to_file("res://scenes/interactive_map.tscn")

func _on_menu_pressed() -> void:
	if bool(GameState.last_result.get("game_over", false)):
		GameState.restore_attempts()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
