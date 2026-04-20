extends CharacterBody2D

@export var move_speed: float = 250.0

func _physics_process(_delta: float) -> void:
	var input_dir := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	velocity = input_dir.normalized() * move_speed
	move_and_slide()

	var viewport_rect := get_viewport_rect()
	global_position.x = clamp(global_position.x, 24.0, viewport_rect.size.x - 24.0)
	global_position.y = clamp(global_position.y, 24.0, viewport_rect.size.y - 24.0)
