extends Control

func _ready() -> void:
	AudioManager.play_lobby_loop()
	_apply_language()
	$Panel/VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$Panel/VBoxContainer/InstructionsButton.pressed.connect(_on_instructions_pressed)
	$Panel/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	$SettingsButton.pressed.connect(_on_settings_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/interactive_map.tscn")

func _on_instructions_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/instructions.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _apply_language() -> void:
	var ar := GameState.current_language == "ar"
	$Panel/VBoxContainer/TitleLabel.text = "🌟 مطاردة الجواهر" if ar else "🌟 Gem Chase"
	$Panel/VBoxContainer/SubtitleLabel.text = "اجمع الجواهر واهرب من الاعداء" if ar else "Collect gems and dodge enemies"
	$Panel/VBoxContainer/FeatureLabel.text = "✨ 3 مستويات + 3 ارواح + خريطة تفاعلية" if ar else "✨ 3 Levels + 3 Lives + Interactive Map"
	$Panel/VBoxContainer/StartButton.text = "▶️ ابدأ المغامرة" if ar else "▶️ Start Adventure"
	$Panel/VBoxContainer/InstructionsButton.text = "📖 تعليمات اللعبة" if ar else "📖 How To Play"
	$Panel/VBoxContainer/QuitButton.text = "❌ خروج" if ar else "❌ Quit"
	$SettingsButton.text = "⚙️ الاعدادات" if ar else "⚙️ Settings"
