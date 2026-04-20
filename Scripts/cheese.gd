extends Area2D

@export var score_value: int = 10

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		var level = get_tree().current_scene
		if level.has_method("add_score"):
			level.add_score(score_value)
		queue_free()
