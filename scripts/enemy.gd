extends Area2D

signal player_hit

@export var speed: float = 90.0
@export var enemy_texture_path: String = "res://assets/sprites/bomb.png"
var direction := Vector2.RIGHT

func _ready() -> void:
	_apply_visual()
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

func _apply_visual() -> void:
	var sprite: Sprite2D = $Sprite2D
	var fallback_visual: Polygon2D = $Visual
	if ResourceLoader.exists(enemy_texture_path):
		var texture := load(enemy_texture_path) as Texture2D
		if texture:
			sprite.texture = texture
			var base_size = max(texture.get_size().x, texture.get_size().y)
			var target_size = 48.0
			var scale_factor = target_size / max(1.0, base_size)
			sprite.scale = Vector2.ONE * scale_factor
			sprite.visible = true
			fallback_visual.visible = false
			return
	sprite.visible = false
	fallback_visual.visible = true
