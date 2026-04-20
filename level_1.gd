extends Node2D

var score: int = 0

@onready var score_label: Label = $CanvasLayer/ScoreLabel

func add_score(amount: int) -> void:
	score += amount
	score_label.text = "Score: " + str(score)
