extends Control

class_name InteractiveMap

const LEVEL_BUTTON_SIZE := 80.0
const LEVEL_BUTTON_RADIUS := 40.0
const LINE_WIDTH := 4.0
const PADDING := 100.0

var level_buttons: Array[Control] = []
var level_positions: Array[Vector2] = []
var hovered_level: int = -1

func _ready() -> void:
	set_process_input(true)
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$ColorRect.z_index = -100
	_create_level_buttons()
	_update_button_states()
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
	_draw_connecting_lines()
	_draw_level_buttons()

func _draw_connecting_lines() -> void:
	# رسم الخطوط التي تربط بين المستويات
	var levels_count = GameState.LEVELS.size()
	
	for i in range(levels_count - 1):
		var start_pos = level_positions[i]
		var end_pos = level_positions[i + 1]
		
		# تحديد لون الخط بناءً على حالة المستوى
		var line_color: Color
		if GameState.unlocked_level > i:
			line_color = Color(0.2, 0.9, 0.2)  # أخضر فاتح
		elif GameState.unlocked_level == i:
			line_color = Color(1.0, 0.9, 0.2)  # أصفر فاتح
		else:
			line_color = Color(0.2, 0.2, 0.2)  # رمادي غامق
		
		draw_line(start_pos, end_pos, line_color, LINE_WIDTH)

func _draw_level_buttons() -> void:
	var levels_count = GameState.LEVELS.size()
	
	for i in range(levels_count):
		var pos = level_positions[i]
		var level_data = GameState.LEVELS[i]
		
		# تحديد حالة المستوى
		var is_locked = i > GameState.unlocked_level
		var is_completed = i < GameState.unlocked_level
		var is_current = i == GameState.unlocked_level
		var is_hovered = i == hovered_level
		
		# تحديد لون الزر
		var button_color: Color
		if is_locked:
			button_color = Color(0.2, 0.2, 0.2)  # رمادي (مقفول)
		elif is_completed:
			button_color = Color(0.1, 0.7, 0.1)  # أخضر (مكتمل)
		elif is_current:
			button_color = Color(0.9, 0.8, 0.1)  # أصفر (متاح)
		else:
			button_color = Color(0.3, 0.5, 1.0)  # أزرق
		
		# تطبيق تأثير المرور فوق الزر
		var scale_factor = 1.0
		if is_hovered and not is_locked:
			button_color = button_color.lightened(0.2)
			scale_factor = 1.15
		
		var scaled_radius = LEVEL_BUTTON_RADIUS * scale_factor
		
		# رسم ظل الزر
		draw_circle(pos + Vector2(3, 3), scaled_radius, Color(0, 0, 0, 0.3))
		
		# رسم دائرة الزر
		draw_circle(pos, scaled_radius, button_color)
		
		# رسم حد الزر
		var border_color = Color.WHITE if is_hovered else Color(0.8, 0.8, 0.8)
		var border_width = 3.0 if is_hovered else 2.0
		draw_circle(pos, scaled_radius, border_color, border_width)
		
		# رسم رقم المستوى
		var level_number = str(i + 1)
		var font = get_theme_font("font")
		if not font:
			font = ThemeDB.fallback_font
		var font_size = 36
		
		var text_size = font.get_string_size(level_number, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var text_pos = pos - text_size / 2
		
		draw_string(font, text_pos, level_number, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.WHITE)
		
		# إضافة أيقونة الحالة
		if is_locked:
			_draw_lock_icon(pos)
		elif is_completed:
			_draw_checkmark(pos)

func _draw_lock_icon(pos: Vector2) -> void:
	# رسم أيقونة قفل بسيطة
	var lock_size = 20.0
	var lock_rect = Rect2(pos.x - lock_size/2, pos.y + lock_size/4, lock_size, lock_size)
	draw_rect(lock_rect, Color.RED, false, 2.0)

func _draw_checkmark(pos: Vector2) -> void:
	# رسم علامة صح بسيطة
	var check_size = 15.0
	var check_start = pos - Vector2(check_size/3, 0)
	var check_mid = pos + Vector2(0, check_size/3)
	var check_end = pos + Vector2(check_size/2, -check_size/3)
	
	draw_line(check_start, check_mid, Color(0, 1, 0), 2.5)
	draw_line(check_mid, check_end, Color(0, 1, 0), 2.5)

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
	# تحديث حالات الأزرار بناءً على حالة اللعبة
	queue_redraw()

func _update_status_label() -> void:
	var levels_total = GameState.LEVELS.size()
	var status_text = "💰 النقاط: %d | ❤️ الأرواح: %d | ✅ مكتمل: %d/%d" % [
		GameState.total_score,
		GameState.attempts_left,
		GameState.levels_won,
		levels_total
	]
	$StatusLabel.text = status_text

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_reset_pressed() -> void:
	GameState.reset_run()
	_update_button_states()
	_update_status_label()
