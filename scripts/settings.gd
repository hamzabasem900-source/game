extends Control

class_name SettingsMenu

func _ready() -> void:
	AudioManager.play_lobby_loop()
	$Panel/VBoxContainer/SoundToggle.pressed.connect(_on_sound_toggled)
	$Panel/VBoxContainer/MusicToggle.pressed.connect(_on_music_toggled)
	$Panel/VBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	
	_update_toggle_states()

func _update_toggle_states() -> void:
	var sound_status = "🔊 مفعلة" if (AudioManager and AudioManager.sound_enabled) else "🔇 معطلة"
	var music_status = "🎵 مفعلة" if (AudioManager and AudioManager.music_enabled) else "🎶 معطلة"
	
	$Panel/VBoxContainer/SoundToggle.text = "الأصوات: %s" % sound_status
	$Panel/VBoxContainer/MusicToggle.text = "الموسيقى: %s" % music_status

func _on_sound_toggled() -> void:
	if AudioManager:
		AudioManager.sound_enabled = !AudioManager.sound_enabled
	_update_toggle_states()

func _on_music_toggled() -> void:
	if AudioManager:
		AudioManager.music_enabled = !AudioManager.music_enabled
		if AudioManager.music_enabled:
			AudioManager.play_lobby_loop()
		else:
			AudioManager.stop_lobby_loop()
			AudioManager.stop_game_loop()
	_update_toggle_states()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
