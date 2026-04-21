extends Control

class_name SettingsMenu

func _ready() -> void:
	AudioManager.play_lobby_loop()
	$Panel/VBoxContainer/LanguageButton.pressed.connect(_on_language_toggle)
	$Panel/VBoxContainer/SfxToggle.pressed.connect(_on_sfx_toggle)
	$Panel/VBoxContainer/MusicToggle.pressed.connect(_on_music_toggled)
	$Panel/VBoxContainer/ResetProgressButton.pressed.connect(_on_reset_progress)
	$Panel/VBoxContainer/WhatsAppButton.pressed.connect(_on_whatsapp_pressed)
	$Panel/VBoxContainer/EmailButton.pressed.connect(_on_email_pressed)
	$Panel/VBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	_update_labels()

func _status_text(enabled: bool) -> String:
	if GameState.current_language == "ar":
		return "مفعل" if enabled else "معطل"
	return "On" if enabled else "Off"

func _update_labels() -> void:
	var ar := GameState.current_language == "ar"
	$Panel/VBoxContainer/TitleLabel.text = "الاعدادات" if ar else "Settings"
	$Panel/VBoxContainer/LanguageButton.text = "اللغة: عربي" if ar else "Language: English"
	$Panel/VBoxContainer/SfxToggle.text = (("المؤثرات الصوتية" if ar else "Sound Effects") + ": " + _status_text(AudioManager.sound_enabled))
	$Panel/VBoxContainer/MusicToggle.text = (("الموسيقى" if ar else "Music") + ": " + _status_text(AudioManager.music_enabled))
	$Panel/VBoxContainer/ResetProgressButton.text = "اعادة تعيين التقدم" if ar else "Reset Progress"
	$Panel/VBoxContainer/AboutLabel.text = "عن اللعبة: مطاردة جواهر تعليمية سريعة وممتعة" if ar else "About: A fast and fun educational gem chase game"
	$Panel/VBoxContainer/WhatsAppButton.text = "تواصل واتساب: 0799451433" if ar else "WhatsApp Contact: 0799451433"
	$Panel/VBoxContainer/EmailButton.text = "البريد: hamzabasem900@gmail.com" if ar else "Email: hamzabasem900@gmail.com"
	$Panel/VBoxContainer/BackButton.text = "عودة" if ar else "Back"

func _on_language_toggle() -> void:
	GameState.current_language = "en" if GameState.current_language == "ar" else "ar"
	_update_labels()

func _on_sfx_toggle() -> void:
	AudioManager.sound_enabled = !AudioManager.sound_enabled
	_update_labels()

func _on_music_toggled() -> void:
	AudioManager.music_enabled = !AudioManager.music_enabled
	if AudioManager.music_enabled:
		AudioManager.play_lobby_loop()
	else:
		AudioManager.stop_lobby_loop()
		AudioManager.stop_game_loop()
	_update_labels()

func _on_reset_progress() -> void:
	GameState.reset_run()
	_update_labels()

func _on_whatsapp_pressed() -> void:
	OS.shell_open("https://wa.me/962799451433")

func _on_email_pressed() -> void:
	OS.shell_open("mailto:hamzabasem900@gmail.com")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
