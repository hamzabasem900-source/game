extends Control

func _ready() -> void:
	_apply_background("settings_bg")
	var language_option: OptionButton = $Panel/VBoxContainer/LanguageOption
	language_option.clear()
	language_option.add_item("العربية", 0)
	language_option.add_item("English", 1)
	language_option.selected = 0 if GameState.language == "ar" else 1

	$Panel/VBoxContainer/SfxCheck.button_pressed = GameState.sfx_enabled
	$Panel/VBoxContainer/MusicCheck.button_pressed = GameState.music_enabled
	$Panel/VBoxContainer/VolumeSlider.value = GameState.master_volume

	language_option.item_selected.connect(_on_language_changed)
	$Panel/VBoxContainer/SfxCheck.toggled.connect(func(v: bool) -> void: GameState.sfx_enabled = v)
	$Panel/VBoxContainer/MusicCheck.toggled.connect(func(v: bool) -> void: GameState.music_enabled = v)
	$Panel/VBoxContainer/VolumeSlider.value_changed.connect(func(v: float) -> void: GameState.master_volume = v)
	$Panel/VBoxContainer/BackButton.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))

func _on_language_changed(index: int) -> void:
	GameState.language = "ar" if index == 0 else "en"

func _apply_background(name_no_ext: String) -> void:
	var path := "res://user_assets/backgrounds/%s.png" % name_no_ext
	if ResourceLoader.exists(path):
		$Background.texture = load(path)
