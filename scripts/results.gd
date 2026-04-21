extends Control

func _ready() -> void:
	var result_data := GameState.last_result
	var ar := GameState.current_language == "ar"
	var passed: bool = bool(result_data.get("passed", false))
	var game_over: bool = bool(result_data.get("game_over", false))
	var level_score: int = int(result_data.get("level_score", 0))
	var target: int = int(result_data.get("target", 0))
	
	if game_over:
		AudioManager.stop_lobby_loop()
	else:
		AudioManager.play_lobby_loop()
	
	if game_over:
		$Panel/VBoxContainer/TitleLabel.text = "💀 انتهت اللعبة" if ar else "💀 GAME OVER"
		$Panel/VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		$Panel/VBoxContainer/MessageLabel.text = ("انتهت الارواح. نقاط هذا المستوى: %d." % level_score) if ar else ("No lives left. Level score: %d." % level_score)
		$Panel/VBoxContainer/MapButton.text = "العودة الى الخريطة" if ar else "Back To Map"
	elif passed:
		$Panel/VBoxContainer/TitleLabel.text = "🏆 فوز" if ar else "🏆 YOU WIN"
		$Panel/VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color(0.25, 1.0, 0.45))
		$Panel/VBoxContainer/MessageLabel.text = ("احرزت %d نقطة (الهدف: %d)." % [level_score, target]) if ar else ("You scored %d (target: %d)." % [level_score, target])
		$Panel/VBoxContainer/MapButton.text = "المستوى التالي / الخريطة" if ar else "Next Level / Map"
	else:
		$Panel/VBoxContainer/TitleLabel.text = "💀 انتهت اللعبة" if ar else "💀 GAME OVER"
		$Panel/VBoxContainer/TitleLabel.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		$Panel/VBoxContainer/MessageLabel.text = ("النقاط %d اقل من الهدف %d." % [level_score, target]) if ar else ("Score %d is below target %d." % [level_score, target])
		$Panel/VBoxContainer/MapButton.text = "اعادة المحاولة من الخريطة" if ar else "Retry From Map"

	$Panel/VBoxContainer/TotalLabel.text = ("💰 اجمالي النقاط (بعد الانتصارات): %d" % GameState.total_score) if ar else ("💰 Total score (wins only): %d" % GameState.total_score)
	$Panel/VBoxContainer/AttemptsLabel.text = ("❤️ الارواح المتبقية: %d" % GameState.attempts_left) if ar else ("❤️ Remaining lives: %d" % GameState.attempts_left)
	$Panel/VBoxContainer/MenuButton.text = "القائمة الرئيسية" if ar else "Main Menu"
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
