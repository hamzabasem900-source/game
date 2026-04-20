extends Area2D

signal player_hit

@export var speed: float = 90.0
var direction := Vector2.RIGHT

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var angle := randf_range(0.0, TAU)
	direction = Vector2.RIGHT.rotated(angle)

func _process(delta: float) -> void:
	global_position += direction * speed * delta
	var viewport_rect := get_viewport_rect()
	if global_position.x <= 16.0 or global_position.x >= viewport_rect.size.x - 16.0:
		direction.x *= -1.0
	if global_position.y <= 16.0 or global_position.y >= viewport_rect.size.y - 16.0:
		direction.y *= -1.0

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_hit.emit()
