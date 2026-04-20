extends Control

func _ready() -> void:
	_apply_background("instructions_bg")
	$Panel/VBoxContainer/BackButton.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _apply_background(name_no_ext: String) -> void:
	var path := "res://user_assets/backgrounds/%s.png" % name_no_ext
	if ResourceLoader.exists(path):
		$Background.texture = load(path)
