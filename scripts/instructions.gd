extends Control

func _ready() -> void:
	AudioManager.play_lobby_loop()
	_apply_language()
	$Panel/VBoxContainer/BackButton.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _apply_language() -> void:
	var ar := GameState.current_language == "ar"
	$Panel/VBoxContainer/Title.text = "📖 تعليمات اللعبة" if ar else "📖 How To Play"
	$Panel/VBoxContainer/BackButton.text = "◀️ عودة للقائمة" if ar else "◀️ Back to Menu"
	if ar:
		$Panel/VBoxContainer/Body.text = "[right]\n⌨️ التحكم:\n  • حرك الشخصية باسهم الاتجاه او WASD\n\n🎯 الهدف:\n  • اجمع العناصر الصفراء 💛 لزيادة النقاط\n  • حقق الهدف المطلوب قبل انتهاء الوقت\n\n⚠️ الخطر:\n  • تجنب الاعداء الحمراء 🔴\n  • كل اصطدام ينقص المحاولات\n\n⏱️ الوقت والصعوبة:\n  • يوجد وقت محدد لكل مستوى\n  • الصعوبة تزداد في كل مستوى\n[/right]"
	else:
		$Panel/VBoxContainer/Body.text = "[left]\n⌨️ Controls:\n  • Move with Arrow Keys or WASD\n\n🎯 Goal:\n  • Collect yellow gems 💛\n  • Reach target score before time ends\n\n⚠️ Danger:\n  • Avoid red enemies 🔴\n  • Each hit reduces lives\n\n⏱️ Time & Difficulty:\n  • Each level has a time limit\n  • Difficulty increases per level\n[/left]"
