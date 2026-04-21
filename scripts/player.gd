extends CharacterBody2D

@export var move_speed: float = 250.0

func _ready() -> void:
	_ensure_input_bindings()

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

func _ensure_input_bindings() -> void:
	_bind_key("move_left", KEY_A)
	_bind_key("move_right", KEY_D)
	_bind_key("move_up", KEY_W)
	_bind_key("move_down", KEY_S)
	_bind_key("move_left", KEY_LEFT)
	_bind_key("move_right", KEY_RIGHT)
	_bind_key("move_up", KEY_UP)
	_bind_key("move_down", KEY_DOWN)

func _bind_key(action: StringName, key: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.keycode == key:
			return
	var input_event := InputEventKey.new()
	input_event.keycode = key
	InputMap.action_add_event(action, input_event)
