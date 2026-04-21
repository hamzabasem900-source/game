extends Control

class_name SettingsMenu

func _ready() -> void:
	AudioManager.play_lobby_loop()
	$Panel/VBoxContainer/LanguageButton.pressed.connect(_on_language_toggle)
	$Panel/VBoxContainer/MasterSoundToggle.pressed.connect(_on_master_sound_toggle)
	$Panel/VBoxContainer/MusicToggle.pressed.connect(_on_music_toggled)
	$Panel/VBoxContainer/LobbyMusicToggle.pressed.connect(_on_lobby_music_toggle)
	$Panel/VBoxContainer/GameMusicToggle.pressed.connect(_on_game_music_toggle)
	$Panel/VBoxContainer/PickupToggle.pressed.connect(_on_pickup_toggle)
	$Panel/VBoxContainer/DangerToggle.pressed.connect(_on_danger_toggle)
	$Panel/VBoxContainer/WinToggle.pressed.connect(_on_win_toggle)
	$Panel/VBoxContainer/GameOverToggle.pressed.connect(_on_game_over_toggle)
	$Panel/VBoxContainer/ResetProgressButton.pressed.connect(_on_reset_progress)
	$Panel/VBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	_update_toggle_states()

func _status_text(enabled: bool) -> String:
	return GameState.tr_text("enabled") if enabled else GameState.tr_text("disabled")

func _update_toggle_states() -> void:
	var ar := GameState.current_language == "ar"
	$Panel/VBoxContainer/TitleLabel.text = GameState.tr_text("settings_title")
	$Panel/VBoxContainer/LanguageButton.text = GameState.tr_text("lang_label")
	$Panel/VBoxContainer/MasterSoundToggle.text = ("الصوت العام" if ar else "Master Sound") + ": " + _status_text(AudioManager.sound_enabled)
	$Panel/VBoxContainer/MusicToggle.text = ("موسيقى الخلفية" if ar else "Background Music") + ": " + _status_text(AudioManager.music_enabled)
	$Panel/VBoxContainer/LobbyMusicToggle.text = ("موسيقى اللوبي" if ar else "Lobby Music") + ": " + _status_text(AudioManager.lobby_music_enabled)
	$Panel/VBoxContainer/GameMusicToggle.text = ("موسيقى اللعب" if ar else "Game Music") + ": " + _status_text(AudioManager.game_music_enabled)
	$Panel/VBoxContainer/PickupToggle.text = ("صوت الجواهر" if ar else "Pickup Sound") + ": " + _status_text(AudioManager.pickup_enabled)
	$Panel/VBoxContainer/DangerToggle.text = ("صوت الخطر" if ar else "Danger Sound") + ": " + _status_text(AudioManager.danger_enabled)
	$Panel/VBoxContainer/WinToggle.text = ("صوت الفوز" if ar else "Win Sound") + ": " + _status_text(AudioManager.win_enabled)
	$Panel/VBoxContainer/GameOverToggle.text = ("صوت الخسارة" if ar else "Game Over Sound") + ": " + _status_text(AudioManager.game_over_enabled)
	$Panel/VBoxContainer/ResetProgressButton.text = "اعادة تعيين التقدم" if ar else "Reset Progress"
	$Panel/VBoxContainer/BackButton.text = "عودة" if ar else "Back"

func _on_language_toggle() -> void:
	GameState.current_language = "en" if GameState.current_language == "ar" else "ar"
	_update_toggle_states()

func _on_master_sound_toggle() -> void:
	AudioManager.sound_enabled = !AudioManager.sound_enabled
	_update_toggle_states()

func _on_music_toggled() -> void:
	AudioManager.music_enabled = !AudioManager.music_enabled
	if AudioManager.music_enabled:
		AudioManager.play_lobby_loop()
	else:
		AudioManager.stop_lobby_loop()
		AudioManager.stop_game_loop()
	_update_toggle_states()

func _on_lobby_music_toggle() -> void:
	AudioManager.lobby_music_enabled = !AudioManager.lobby_music_enabled
	if AudioManager.lobby_music_enabled:
		AudioManager.play_lobby_loop()
	else:
		AudioManager.stop_lobby_loop()
	_update_toggle_states()

func _on_game_music_toggle() -> void:
	AudioManager.game_music_enabled = !AudioManager.game_music_enabled
	if not AudioManager.game_music_enabled:
		AudioManager.stop_game_loop()
	_update_toggle_states()

func _on_pickup_toggle() -> void:
	AudioManager.pickup_enabled = !AudioManager.pickup_enabled
	_update_toggle_states()

func _on_danger_toggle() -> void:
	AudioManager.danger_enabled = !AudioManager.danger_enabled
	_update_toggle_states()

func _on_win_toggle() -> void:
	AudioManager.win_enabled = !AudioManager.win_enabled
	_update_toggle_states()

func _on_game_over_toggle() -> void:
	AudioManager.game_over_enabled = !AudioManager.game_over_enabled
	_update_toggle_states()

func _on_reset_progress() -> void:
	GameState.reset_run()
	_update_toggle_states()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
