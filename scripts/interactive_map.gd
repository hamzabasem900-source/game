extends Control

class_name InteractiveMap

const LEVEL_BUTTON_SIZE := 80.0
const LEVEL_BUTTON_RADIUS := 40.0
const LINE_WIDTH := 10.0
const PADDING := 100.0

var level_buttons: Array[Control] = []
var level_positions: Array[Vector2] = []
var hovered_level: int = -1

func _ready() -> void:
	AudioManager.play_lobby_loop()
	set_process_input(true)
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$ColorRect.z_index = -100
	_create_level_buttons()
	_update_button_states()
	_apply_language()
	_update_status_label()
	
	$BackButton.pressed.connect(_on_back_pressed)
	$ResetButton.pressed.connect(_on_reset_pressed)

func _create_level_buttons() -> void:
	var levels_count = GameState.LEVELS.size()
	var viewport_size = get_viewport_rect().size
	var available_width = viewport_size.x - (PADDING * 2)
	var available_height = viewport_size.y - (PADDING * 3)
	
	var positions: Array[Vector2] = []
	if levels_count == 3:
		# مسار تصاعدي لثلاثة مستويات
		positions.append(Vector2(PADDING + available_width * 0.20, PADDING + available_height * 0.68))
		positions.append(Vector2(PADDING + available_width * 0.50, PADDING + available_height * 0.42))
		positions.append(Vector2(PADDING + available_width * 0.80, PADDING + available_height * 0.62))
	else:
		# ترتيب أفقي عام لباقي الحالات
		for i in range(levels_count):
			var x = PADDING + (available_width / (levels_count + 1)) * (i + 1)
			var y = viewport_size.y / 2
			positions.append(Vector2(x, y))
	
	level_positions = positions
	
	# حذف الأزرار القديمة إن وجدت
	for btn in level_buttons:
		btn.queue_free()
	level_buttons.clear()
	
	# إنشاء أزرار جديدة
	for i in range(levels_count):
		var btn = Control.new()
		btn.custom_minimum_size = Vector2(LEVEL_BUTTON_SIZE, LEVEL_BUTTON_SIZE)
		btn.position = positions[i] - Vector2(LEVEL_BUTTON_SIZE / 2, LEVEL_BUTTON_SIZE / 2)
		add_child(btn)
		level_buttons.append(btn)

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if level_positions.is_empty():
		return
	_draw_map_background()
	_draw_connecting_lines()
	_draw_level_buttons()

func _draw_map_background() -> void:
	var size = get_viewport_rect().size
	# جزر/بقع لونية كخلفية الخريطة
	draw_circle(Vector2(size.x * 0.28, size.y * 0.42), 220, Color(0.18, 0.62, 0.46, 0.30))
	draw_circle(Vector2(size.x * 0.52, size.y * 0.63), 280, Color(0.20, 0.50, 0.78, 0.28))
	draw_circle(Vector2(size.x * 0.72, size.y * 0.36), 210, Color(0.34, 0.72, 0.34, 0.24))
	# نجوم بسيطة لزيادة الحيوية
	for i in range(18):
		var x = fmod((i * 177.0) + 120.0, size.x - 60.0) + 30.0
		var y = fmod((i * 121.0) + 90.0, size.y - 140.0) + 70.0
		draw_circle(Vector2(x, y), 1.6, Color(0.62, 0.82, 1.0, 0.28))

func _draw_connecting_lines() -> void:
	# رسم الخطوط التي تربط بين المستويات
	var levels_count = GameState.LEVELS.size()
	
	for i in range(levels_count - 1):
		var start_pos = level_positions[i]
		var end_pos = level_positions[i + 1]
		var mid = (start_pos + end_pos) / 2.0 + Vector2(0, -32.0 if i % 2 == 0 else 28.0)
		
		# تحديد لون الخط بناء على حالة المستوى
		var line_color: Color
		if GameState.unlocked_level > i:
			line_color = Color(0.30, 0.85, 0.40)  # اخضر للمسار المكتمل
		else:
			line_color = Color(1.0, 0.86, 0.22)  # اصفر لباقي المسار
		
		var curve_points := PackedVector2Array([start_pos, mid, end_pos])
		draw_polyline(curve_points, Color(0.02, 0.04, 0.12, 0.45), LINE_WIDTH + 4.0)
		draw_polyline(curve_points, line_color, LINE_WIDTH)

func _draw_level_buttons() -> void:
	var levels_count = GameState.LEVELS.size()
	
	for i in range(levels_count):
		var pos = level_positions[i]
		
		# تحديد حالة المستوى
		var is_locked = i > GameState.unlocked_level
		var is_completed = i < GameState.unlocked_level
		var is_current = i == GameState.unlocked_level
		var is_hovered = i == hovered_level
		
		# تحديد لون الزر
		var button_color: Color = Color(1.0, 0.86, 0.22)  # اصفر افتراضي
		if is_completed:
			button_color = Color(0.28, 0.83, 0.38)  # اخضر للمكتمل
		
		# تطبيق تأثير المرور فوق الزر
		var scale_factor = 1.0
		if is_hovered and not is_locked:
			button_color = button_color.lightened(0.2)
			scale_factor = 1.15
		
		var scaled_radius = LEVEL_BUTTON_RADIUS * scale_factor
		var pulse = 0.0
		if is_current and not is_locked:
			pulse = sin(Time.get_ticks_msec() / 160.0) * 4.0
		
		# رسم ظل الزر
		draw_circle(pos + Vector2(5, 5), scaled_radius + 4.0, Color(0, 0, 0, 0.33))
		
		# رسم دائرة الزر
		draw_circle(pos, scaled_radius + pulse, button_color)
		
		# رسم حد الزر
		var border_color = Color(1.0, 0.95, 0.55) if is_hovered else Color(0.88, 0.72, 0.05)
		var border_width = 3.0 if is_hovered else 2.0
		draw_circle(pos, scaled_radius + pulse, border_color, border_width)
		
		# رسم رقم المستوى
		var level_number = str(i + 1)
		var font = get_theme_font("font")
		if not font:
			font = ThemeDB.fallback_font
		var font_size = 36
		var text_size = font.get_string_size(level_number, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var text_pos = pos + Vector2(-text_size.x / 2.0, text_size.y / 2.7)
		draw_string(font, text_pos, level_number, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.07, 0.12, 0.22, 1))
		
		# إضافة أيقونة الحالة
		if is_locked:
			_draw_lock_icon(pos)
		elif is_completed:
			_draw_checkmark(pos)
		elif is_current:
			_draw_pin_icon(pos + Vector2(0, -60))

func _draw_lock_icon(pos: Vector2) -> void:
	# رسم قفل واضح ومتناسق في منتصف الدائرة
	var body_size = Vector2(18, 14)
	var body_pos = pos + Vector2(-body_size.x / 2.0, 2)
	var body_rect = Rect2(body_pos, body_size)
	draw_rect(body_rect, Color(0.14, 0.18, 0.30, 0.95), true)
	draw_rect(body_rect, Color(0.95, 0.83, 0.30, 1), false, 1.8)
	var shackle_radius = 6.0
	var shackle_center = pos + Vector2(0, 1)
	draw_arc(shackle_center, shackle_radius, PI, TAU, 20, Color(0.14, 0.18, 0.30, 0.95), 3.2)
	draw_arc(shackle_center, shackle_radius + 0.9, PI, TAU, 20, Color(0.95, 0.83, 0.30, 1), 1.3)
	draw_circle(pos + Vector2(0, 9), 1.8, Color(0.95, 0.83, 0.30, 1))

func _draw_checkmark(pos: Vector2) -> void:
	# رسم علامة صح واضحة في منتصف الدائرة
	var check_size = 18.0
	var check_start = pos + Vector2(-check_size * 0.45, 0)
	var check_mid = pos + Vector2(-check_size * 0.12, check_size * 0.35)
	var check_end = pos + Vector2(check_size * 0.48, -check_size * 0.32)
	
	draw_line(check_start, check_mid, Color(0.02, 0.35, 0.08, 0.9), 5.0)
	draw_line(check_mid, check_end, Color(0.02, 0.35, 0.08, 0.9), 5.0)
	draw_line(check_start, check_mid, Color(0.85, 1.0, 0.88, 1), 2.8)
	draw_line(check_mid, check_end, Color(0.85, 1.0, 0.88, 1), 2.8)

func _draw_pin_icon(pos: Vector2) -> void:
	draw_circle(pos, 10, Color(1, 0.2, 0.28, 1))
	draw_circle(pos, 4, Color(1, 1, 1, 0.95))
	draw_polygon(PackedVector2Array([
		pos + Vector2(0, 18),
		pos + Vector2(-6, 8),
		pos + Vector2(6, 8)
	]), [Color(1, 0.2, 0.28, 1)])

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_update_hovered_level(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_level_click(event.position)

func _update_hovered_level(mouse_pos: Vector2) -> void:
	var old_hovered = hovered_level
	hovered_level = -1
	
	for i in range(level_positions.size()):
		var distance = mouse_pos.distance_to(level_positions[i])
		if distance <= LEVEL_BUTTON_RADIUS * 1.2:
			hovered_level = i
			if hovered_level != old_hovered:
				queue_redraw()
			return
	
	if hovered_level != old_hovered:
		queue_redraw()

func _handle_level_click(mouse_pos: Vector2) -> void:
	for i in range(level_positions.size()):
		var distance = mouse_pos.distance_to(level_positions[i])
		if distance <= LEVEL_BUTTON_RADIUS * 1.2:
			# التحقق من أن المستوى متاح (غير مقفول)
			if i <= GameState.unlocked_level:
				_start_level(i)
			return

func _start_level(level_index: int) -> void:
	GameState.begin_level(level_index)
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _update_button_states() -> void:
	# تحديث حالات الازرار بناء على حالة اللعبة
	queue_redraw()

func _update_status_label() -> void:
	var levels_total = GameState.LEVELS.size()
	var status_text: String
	if GameState.current_language == "ar":
		status_text = "💰 النقاط: %d | ❤️ الارواح: %d | ✅ مكتمل: %d/%d" % [
			GameState.total_score,
			GameState.attempts_left,
			GameState.levels_won,
			levels_total
		]
	else:
		status_text = "💰 Score: %d | ❤️ Lives: %d | ✅ Cleared: %d/%d" % [
			GameState.total_score,
			GameState.attempts_left,
			GameState.levels_won,
			levels_total
		]
	$FooterPanel/StatusLabel.text = status_text

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_reset_pressed() -> void:
	GameState.reset_run()
	_update_button_states()
	_update_status_label()

func _apply_language() -> void:
	var ar := GameState.current_language == "ar"
	$HeaderPanel/TitleLabel.text = "🗺️ خريطة المغامرة - 3 مستويات" if ar else "🗺️ Adventure Map - 3 Levels"
	$BackButton.text = "◀️ عودة" if ar else "◀️ Back"
	$ResetButton.text = "🔄 اعادة تعيين" if ar else "🔄 Reset"
