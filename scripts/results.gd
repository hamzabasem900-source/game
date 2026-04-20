extends Control

func _ready() -> void:
	_apply_background("results_bg")
	var status: String = str(GameState.last_result.status)
	var level_score: int = int(GameState.last_result.level_score)
	var target: int = int(GameState.last_result.target)
	var message: String = str(GameState.last_result.message)

	$Panel/VBoxContainer/MessageLabel.text = message
	$Panel/VBoxContainer/ScoreLine.text = "نقاط الجولة: %d / الهدف: %d" % [level_score, target]
	$Panel/VBoxContainer/TotalLabel.text = "إجمالي نقاطك: %d" % GameState.total_score
	$Panel/VBoxContainer/AttemptsLabel.text = "المحاولات المتبقية: %d" % GameState.attempts_left

	match status:
		"final_win":
			$Panel/VBoxContainer/TitleLabel.text = "🏆 فــوز نهائي"
			$Panel/VBoxContainer/PrimaryButton.text = "القائمة الرئيسية"
		"win_level":
			$Panel/VBoxContainer/TitleLabel.text = "✅ فــوز بالمستوى"
			$Panel/VBoxContainer/PrimaryButton.text = "المستوى التالي / الخريطة"
		"game_over":
			$Panel/VBoxContainer/TitleLabel.text = "❌ خسارة"
			$Panel/VBoxContainer/PrimaryButton.text = "إعادة من البداية"
		"lose_level":
			$Panel/VBoxContainer/TitleLabel.text = "⚠️ لم تنجح"
			$Panel/VBoxContainer/PrimaryButton.text = "إعادة المحاولة"
		_:
			$Panel/VBoxContainer/TitleLabel.text = "النتيجة"

	$Panel/VBoxContainer/PrimaryButton.pressed.connect(_on_primary_pressed)
	$Panel/VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)

func _on_primary_pressed() -> void:
	var status: String = str(GameState.last_result.status)
	match status:
		"final_win":
			GameState.reset_run()
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		"win_level":
			get_tree().change_scene_to_file("res://scenes/map.tscn")
		"game_over":
			GameState.reset_run()
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		"lose_level":
			get_tree().change_scene_to_file("res://scenes/game.tscn")
		_:
			get_tree().change_scene_to_file("res://scenes/map.tscn")

func _on_menu_pressed() -> void:
	GameState.reset_run()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _apply_background(name_no_ext: String) -> void:
	var path := "res://user_assets/backgrounds/%s.png" % name_no_ext
	if ResourceLoader.exists(path):
		$Background.texture = load(path)
