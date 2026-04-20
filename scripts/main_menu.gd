extends Control

func _ready() -> void:
	$Panel/VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$Panel/VBoxContainer/InstructionsButton.pressed.connect(_on_instructions_pressed)
	$Panel/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_start_pressed() -> void:
	GameState.reset_run()
	AudioManager.play_start()
	get_tree().change_scene_to_file("res://scenes/map.tscn")

func _on_instructions_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/instructions.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
