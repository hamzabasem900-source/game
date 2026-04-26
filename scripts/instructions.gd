extends Control

@onready var title_label: Label = $Panel/VBoxContainer/Title
@onready var subtitle_label: Label = $Panel/VBoxContainer/Subtitle
@onready var details_label: RichTextLabel = $Panel/VBoxContainer/Details
@onready var back_button: Button = $Panel/VBoxContainer/BackButton

@onready var cards := {
	"control": $Panel/VBoxContainer/Cards/ControlCard,
	"goal": $Panel/VBoxContainer/Cards/GoalCard,
	"danger": $Panel/VBoxContainer/Cards/DangerCard,
	"time": $Panel/VBoxContainer/Cards/TimeCard,
}

var card_content: Dictionary = {}

func _ready() -> void:
	AudioManager.play_lobby_loop()
	_apply_language()
	_connect_cards()
	back_button.pressed.connect(_on_back_pressed)
	_select_card("control")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _connect_cards() -> void:
	for key: String in cards.keys():
		(cards[key] as Button).pressed.connect(func() -> void:
			_select_card(key)
		)


func _select_card(card_key: String) -> void:
	for key: String in cards.keys():
		(cards[key] as Button).button_pressed = key == card_key

	var align_open := "[right]" if GameState.current_language == "ar" else "[left]"
	var align_close := "[/right]" if GameState.current_language == "ar" else "[/left]"
	details_label.text = "%s%s%s" % [align_open, card_content.get(card_key, ""), align_close]


func _apply_language() -> void:
	var ar := GameState.current_language == "ar"

	if ar:
		title_label.text = "✨ تعليمات اللعبة التفاعلية"
		subtitle_label.text = "اختار بطاقة علشان تشوف التفاصيل"
		back_button.text = "◀️ عودة للقائمة"
		(cards["control"] as Button).text = "⌨️ التحكم"
		(cards["goal"] as Button).text = "🎯 الهدف"
		(cards["danger"] as Button).text = "⚠️ الخطر"
		(cards["time"] as Button).text = "⏱️ الوقت والصعوبة"
		card_content = {
			"control": "[b]طريقة اللعب:[/b]\n• حرك الشخصية بأسهم الاتجاه أو WASD.\n• حاول تتحكم بحركة ناعمة وسريعة.",
			"goal": "[b]مهمتك:[/b]\n• اجمع العناصر الصفراء 💛 لزيادة النقاط.\n• حقق الهدف المطلوب قبل انتهاء المؤقت.",
			"danger": "[b]انتبه:[/b]\n• تجنب الأعداء الحمراء 🔴 قدر الإمكان.\n• كل اصطدام يقلل عدد المحاولات.",
			"time": "[b]التحدي:[/b]\n• كل مستوى له وقت محدد لازم تخلص خلاله.\n• كل ما تتقدم، اللعبة تصير أصعب وأسرع.",
		}
	else:
		title_label.text = "✨ Interactive Game Guide"
		subtitle_label.text = "Pick a card to show details"
		back_button.text = "◀️ Back to Menu"
		(cards["control"] as Button).text = "⌨️ Controls"
		(cards["goal"] as Button).text = "🎯 Goal"
		(cards["danger"] as Button).text = "⚠️ Danger"
		(cards["time"] as Button).text = "⏱️ Time & Difficulty"
		card_content = {
			"control": "[b]How to move:[/b]\n• Move with Arrow Keys or WASD.\n• Smooth, quick movement keeps you safe.",
			"goal": "[b]Your mission:[/b]\n• Collect yellow gems 💛 to increase score.\n• Reach target score before the timer ends.",
			"danger": "[b]Watch out:[/b]\n• Avoid red enemies 🔴 whenever possible.\n• Every hit reduces your remaining lives.",
			"time": "[b]Challenge scaling:[/b]\n• Every level has a strict time limit.\n• Difficulty ramps up each level.",
		}
