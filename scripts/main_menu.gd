extends Control

const BG_STARS := 70
const BG_GEMS := 10
const PARALLAX_STRENGTH := 18.0

var _time_passed := 0.0
var _pointer_ratio := Vector2(0.5, 0.5)
var _smoothed_pointer_ratio := Vector2(0.5, 0.5)
var _panel_base_pos := Vector2.ZERO

func _ready() -> void:
	AudioManager.play_lobby_loop()
	set_process(true)
	set_process_input(true)
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel_base_pos = $Panel.position
	_apply_language()
	$Panel/VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$Panel/VBoxContainer/InstructionsButton.pressed.connect(_on_instructions_pressed)
	$Panel/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	$SettingsButton.pressed.connect(_on_settings_pressed)
	_setup_button_feedback($Panel/VBoxContainer/StartButton)
	_setup_button_feedback($Panel/VBoxContainer/InstructionsButton)
	_setup_button_feedback($Panel/VBoxContainer/QuitButton)
	_setup_button_feedback($SettingsButton)
	queue_redraw()

func _process(delta: float) -> void:
	_time_passed += delta
	_smoothed_pointer_ratio = _smoothed_pointer_ratio.lerp(_pointer_ratio, min(delta * 6.0, 1.0))
	var viewport_size = get_viewport_rect().size
	var target_offset = (_smoothed_pointer_ratio - Vector2(0.5, 0.5)) * PARALLAX_STRENGTH
	$Panel.position = _panel_base_pos - target_offset
	$SettingsButton.position = Vector2(50, 50) - target_offset * 0.4
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var viewport_size = get_viewport_rect().size
		if viewport_size.x > 0.0 and viewport_size.y > 0.0:
			_pointer_ratio = Vector2(
				clamp(event.position.x / viewport_size.x, 0.0, 1.0),
				clamp(event.position.y / viewport_size.y, 0.0, 1.0)
			)

func _draw() -> void:
	var size = get_viewport_rect().size
	var center = size * 0.5
	var pulse = 0.06 + (sin(_time_passed * 1.1) * 0.03)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.04, 0.14, 1.0), true)
	draw_circle(center + Vector2(-size.x * 0.2, -size.y * 0.2), size.x * 0.55, Color(0.1, 0.2 + pulse, 0.6, 0.17))
	draw_circle(center + Vector2(size.x * 0.28, size.y * 0.2), size.x * 0.45, Color(0.02, 0.58, 0.92, 0.12))
	draw_circle(center + Vector2(0, size.y * 0.4), size.x * 0.60, Color(0.18, 0.18, 0.45, 0.15))
	_draw_background_paths(size)
	_draw_stars(size)
	_draw_gems(size)

func _draw_background_paths(size: Vector2) -> void:
	var path_color_a = Color(0.26, 0.77, 1.0, 0.25)
	var path_color_b = Color(0.75, 0.94, 1.0, 0.45)
	for i in range(3):
		var offset = (i * 110.0) + sin(_time_passed + i) * 14.0
		var points := PackedVector2Array([
			Vector2(-40, size.y * 0.28 + offset * 0.2),
			Vector2(size.x * 0.25, size.y * 0.15 + offset * 0.1),
			Vector2(size.x * 0.56, size.y * 0.38 - offset * 0.08),
			Vector2(size.x + 40, size.y * 0.24 + offset * 0.16)
		])
		draw_polyline(points, path_color_a, 7.0)
		draw_polyline(points, path_color_b, 2.0)

func _draw_stars(size: Vector2) -> void:
	for i in range(BG_STARS):
		var px = fmod((i * 193.0) + 61.0, size.x - 30.0) + 15.0
		var py = fmod((i * 127.0) + 47.0, size.y - 40.0) + 20.0
		var pulse = 0.4 + 0.6 * (sin(_time_passed * 1.9 + i * 0.7) * 0.5 + 0.5)
		var radius = 0.8 + pulse * 1.8
		draw_circle(Vector2(px, py), radius, Color(0.76, 0.92, 1.0, 0.22 + pulse * 0.5))

func _draw_gems(size: Vector2) -> void:
	for i in range(BG_GEMS):
		var orbit = sin(_time_passed * 0.9 + i * 0.8) * 24.0
		var x = fmod((i * 251.0) + 110.0 + orbit, size.x - 160.0) + 80.0
		var y = fmod((i * 139.0) + 120.0 + orbit * 0.6, size.y - 200.0) + 100.0
		var gem_center = Vector2(x, y)
		var glow = 0.20 + (sin(_time_passed * 1.4 + i) * 0.5 + 0.5) * 0.35
		draw_circle(gem_center, 12.0, Color(0.12, 0.8, 1.0, glow * 0.28))
		var gem = PackedVector2Array([
			gem_center + Vector2(0, -10),
			gem_center + Vector2(8, -2),
			gem_center + Vector2(4, 10),
			gem_center + Vector2(-4, 10),
			gem_center + Vector2(-8, -2)
		])
		draw_polygon(gem, [Color(0.60, 0.95, 1.0, 0.16 + glow)])
		draw_polyline(PackedVector2Array([gem[0], gem[1], gem[2], gem[3], gem[4], gem[0]]), Color(0.75, 1.0, 1.0, 0.80), 1.3)

func _setup_button_feedback(button: Button) -> void:
	button.mouse_entered.connect(func() -> void:
		button.scale = Vector2(1.03, 1.03)
	)
	button.mouse_exited.connect(func() -> void:
		button.scale = Vector2.ONE
	)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/interactive_map.tscn")

func _on_instructions_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/instructions.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _apply_language() -> void:
	var ar := GameState.current_language == "ar"
	$Panel/VBoxContainer/TitleLabel.text = "💎 مطاردة الجواهر" if ar else "💎 Gem Chase"
	$Panel/VBoxContainer/SubtitleLabel.text = "اجمع الجواهر، تفادى الأعداء، واصنع رقمك القياسي!" if ar else "Collect gems, dodge enemies, and set a new high score!"
	$Panel/VBoxContainer/FeatureLabel.text = "⚡ 3 مستويات + 3 أرواح + تحدي سريع ومثير" if ar else "⚡ 3 Levels + 3 Lives + Fast Arcade Challenge"
	$Panel/VBoxContainer/StartButton.text = "▶️ ابدأ المغامرة" if ar else "▶️ Start Adventure"
	$Panel/VBoxContainer/InstructionsButton.text = "📖 تعليمات اللعبة" if ar else "📖 How To Play"
	$Panel/VBoxContainer/QuitButton.text = "❌ خروج" if ar else "❌ Quit"
	$SettingsButton.text = "⚙️ الاعدادات" if ar else "⚙️ Settings"
