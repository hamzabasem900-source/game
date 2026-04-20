extends Node2D

const PLAYFIELD := Rect2(Vector2(40, 120), Vector2(1040, 520))
const PLAYER_SPEED := 320.0
const PLAYER_RADIUS := 22.0
const CAT_RADIUS := 24.0
const CHEESE_RADIUS := 16.0
const SAMPLE_RATE := 44100.0

const LEVELS := [
	{"name": "المستوى 1", "cats": 2, "speed": 140.0, "time": 50.0, "cheese": 6},
	{"name": "المستوى 2", "cats": 4, "speed": 190.0, "time": 40.0, "cheese": 7},
	{"name": "المستوى 3", "cats": 6, "speed": 240.0, "time": 30.0, "cheese": 8}
]

var score := 0
var lives := 3
var level_index := 0
var time_left := 0.0
var invulnerable_time := 0.0
var game_state := "welcome"

var player: Node2D
var cats: Array = []
var cheeses: Array = []

@onready var world: Node2D = $World
@onready var hud: CanvasLayer = $HUD
@onready var title_label: Label = $HUD/TitleLabel
@onready var description_label: RichTextLabel = $HUD/DescriptionLabel
@onready var status_label: Label = $HUD/StatusLabel
@onready var score_label: Label = $HUD/ScoreLabel
@onready var lives_label: Label = $HUD/LivesLabel
@onready var timer_label: Label = $HUD/TimerLabel
@onready var action_button: Button = $HUD/ActionButton
@onready var start_sound: AudioStreamPlayer = $StartSound
@onready var end_sound: AudioStreamPlayer = $EndSound
@onready var sfx_sound: AudioStreamPlayer = $SfxSound

func _ready() -> void:
	action_button.pressed.connect(_on_action_button_pressed)
	show_welcome()


func _process(delta: float) -> void:
	if game_state != "playing":
		return

	time_left -= delta
	invulnerable_time = max(invulnerable_time - delta, 0.0)
	if time_left <= 0.0:
		finish_game("انتهى الوقت!")
		return

	move_player(delta)
	move_cats(delta)
	check_collisions()
	update_hud_labels()


func _draw() -> void:
	draw_rect(PLAYFIELD, Color(0.12, 0.12, 0.12), false, 3.0)


func _on_action_button_pressed() -> void:
	match game_state:
		"welcome":
			show_instructions()
		"instructions":
			start_game()
		"result":
			show_welcome()


func show_welcome() -> void:
	clear_world()
	game_state = "welcome"
	title_label.text = "لعبة الفأر والجبن"
	description_label.text = "[center]مرحباً!\nاجمع أكبر عدد من قطع الجبن وتجنب القطط.[/center]"
	status_label.text = ""
	action_button.text = "ابدأ"
	score_label.visible = false
	lives_label.visible = false
	timer_label.visible = false


func show_instructions() -> void:
	game_state = "instructions"
	title_label.text = "تعليمات اللعبة"
	description_label.text = "[right]1) تحكم بالفأر باستخدام الأسهم أو WASD.\n2) اجمع الجبن لزيادة النقاط.\n3) تجنب القطط لأن عدد المحاولات محدود.\n4) اللعبة مؤقتة ولكل مستوى صعوبة أعلى.\n5) عندما تصل المحاولات إلى 0 تنتهي اللعبة وتعود للبداية.[/right]"
	status_label.text = ""
	action_button.text = "ابدأ اللعب"


func start_game() -> void:
	score = 0
	lives = 3
	level_index = 0
	play_tone(start_sound, [523.25, 659.25], 0.25)
	start_level(level_index)


func start_level(index: int) -> void:
	clear_world()
	game_state = "playing"
	if index >= LEVELS.size():
		finish_game("ممتاز! أنهيت جميع المستويات.")
		return

	var level_data: Dictionary = LEVELS[index]
	time_left = level_data["time"]
	spawn_player()
	spawn_cheeses(level_data["cheese"])
	spawn_cats(level_data["cats"], level_data["speed"])

	title_label.text = ""
	description_label.text = ""
	status_label.text = level_data["name"]
	action_button.text = ""
	action_button.visible = false
	score_label.visible = true
	lives_label.visible = true
	timer_label.visible = true
	update_hud_labels()


func finish_game(message: String) -> void:
	clear_world()
	game_state = "result"
	play_tone(end_sound, [196.0, 130.81], 0.45)
	title_label.text = "النتيجة النهائية"
	description_label.text = "[center]%s\nالنقاط: %d\nوصلت إلى: %s[/center]" % [message, score, LEVELS[min(level_index, LEVELS.size() - 1)]["name"]]
	status_label.text = ""
	action_button.text = "العودة للبداية"
	action_button.visible = true
	score_label.visible = false
	lives_label.visible = false
	timer_label.visible = false


func spawn_player() -> void:
	player = Node2D.new()
	player.position = PLAYFIELD.get_center()
	player.name = "Player"
	var sprite := Polygon2D.new()
	sprite.color = Color(0.7, 0.9, 1.0)
	sprite.polygon = PackedVector2Array([Vector2(0, -22), Vector2(18, 16), Vector2(-18, 16)])
	player.add_child(sprite)
	world.add_child(player)


func spawn_cheeses(amount: int) -> void:
	for i in amount:
		var cheese := Node2D.new()
		cheese.position = random_point_in_playfield()
		var visual := Polygon2D.new()
		visual.color = Color(1.0, 0.9, 0.2)
		visual.polygon = PackedVector2Array([Vector2(-14, -10), Vector2(14, -8), Vector2(8, 12), Vector2(-10, 8)])
		cheese.add_child(visual)
		world.add_child(cheese)
		cheeses.append(cheese)


func spawn_cats(amount: int, speed: float) -> void:
	for i in amount:
		var cat := Node2D.new()
		cat.position = random_point_in_playfield()
		cat.set_meta("velocity", Vector2.RIGHT.rotated(randf() * TAU) * speed)
		var visual := Polygon2D.new()
		visual.color = Color(1.0, 0.4, 0.4)
		visual.polygon = PackedVector2Array([Vector2(0, -22), Vector2(20, 10), Vector2(8, 22), Vector2(-8, 22), Vector2(-20, 10)])
		cat.add_child(visual)
		world.add_child(cat)
		cats.append(cat)


func move_player(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_key_pressed(KEY_D):
		direction.x += 1
	if Input.is_key_pressed(KEY_W):
		direction.y -= 1
	if Input.is_key_pressed(KEY_S):
		direction.y += 1
	direction = direction.normalized()
	player.position += direction * PLAYER_SPEED * delta
	player.position.x = clampf(player.position.x, PLAYFIELD.position.x + PLAYER_RADIUS, PLAYFIELD.end.x - PLAYER_RADIUS)
	player.position.y = clampf(player.position.y, PLAYFIELD.position.y + PLAYER_RADIUS, PLAYFIELD.end.y - PLAYER_RADIUS)


func move_cats(delta: float) -> void:
	for cat in cats:
		var velocity: Vector2 = cat.get_meta("velocity")
		cat.position += velocity * delta
		if cat.position.x < PLAYFIELD.position.x + CAT_RADIUS or cat.position.x > PLAYFIELD.end.x - CAT_RADIUS:
			velocity.x *= -1
		if cat.position.y < PLAYFIELD.position.y + CAT_RADIUS or cat.position.y > PLAYFIELD.end.y - CAT_RADIUS:
			velocity.y *= -1
		cat.set_meta("velocity", velocity)


func check_collisions() -> void:
	for i in range(cheeses.size() - 1, -1, -1):
		var cheese: Node2D = cheeses[i]
		if player.position.distance_to(cheese.position) <= PLAYER_RADIUS + CHEESE_RADIUS:
			score += 10
			play_tone(sfx_sound, [880.0], 0.08)
			cheese.queue_free()
			cheeses.remove_at(i)

	if cheeses.is_empty():
		level_index += 1
		start_level(level_index)
		return

	if invulnerable_time > 0.0:
		return

	for cat in cats:
		if player.position.distance_to(cat.position) <= PLAYER_RADIUS + CAT_RADIUS:
			lives -= 1
			invulnerable_time = 1.0
			play_tone(sfx_sound, [220.0], 0.12)
			player.position = PLAYFIELD.get_center()
			if lives <= 0:
				finish_game("انتهت المحاولات!")
			return


func update_hud_labels() -> void:
	score_label.text = "النقاط: %d" % score
	lives_label.text = "المحاولات المتبقية: %d" % lives
	timer_label.text = "الوقت: %d" % int(ceil(time_left))


func random_point_in_playfield() -> Vector2:
	return Vector2(
		randf_range(PLAYFIELD.position.x + 50.0, PLAYFIELD.end.x - 50.0),
		randf_range(PLAYFIELD.position.y + 50.0, PLAYFIELD.end.y - 50.0)
	)


func play_tone(player_node: AudioStreamPlayer, freqs: Array, duration: float) -> void:
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = SAMPLE_RATE
	stream.buffer_length = max(duration + 0.1, 0.2)
	player_node.stream = stream
	player_node.play()

	var playback := player_node.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		return

	var frame_count := int(SAMPLE_RATE * duration)
	for i in frame_count:
		var t := float(i) / SAMPLE_RATE
		var sample := 0.0
		for f in freqs:
			sample += sin(TAU * float(f) * t)
		sample /= max(1, freqs.size())
		var envelope := min(1.0, i / (SAMPLE_RATE * 0.02), (frame_count - i) / (SAMPLE_RATE * 0.03))
		var final_sample := float(sample) * envelope * 0.35
		playback.push_frame(Vector2(final_sample, final_sample))


func clear_world() -> void:
	for child in world.get_children():
		child.queue_free()
	cats.clear()
	cheeses.clear()
	player = null
	action_button.visible = true
