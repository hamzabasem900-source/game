extends Area2D

signal player_hit

@export var speed: float = 120.0
@export var chase_weight: float = 0.85

var direction := Vector2.RIGHT
var target: Node2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	direction = Vector2.RIGHT.rotated(randf_range(0.0, TAU))

func set_target(node: Node2D) -> void:
	target = node

func _process(delta: float) -> void:
	if target:
		var to_target := (target.global_position - global_position).normalized()
		direction = direction.lerp(to_target, clamp(chase_weight * delta * 2.0, 0.0, 1.0)).normalized()

	global_position += direction * speed * delta

	var viewport_rect := get_viewport_rect().size
	if global_position.x <= 20.0 or global_position.x >= viewport_rect.x - 20.0:
		direction.x *= -1.0
	if global_position.y <= 90.0 or global_position.y >= viewport_rect.y - 20.0:
		direction.y *= -1.0

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_hit.emit()
