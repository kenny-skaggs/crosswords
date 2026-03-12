class_name WordDisplay extends HBoxContainer

@onready var index_display: Label = %index_display
@onready var character_display: HBoxContainer = %character_display
@onready var hint_display: Label = %hint_display
@onready var hint_input: LineEdit = %hint_input

@onready var button: Button = %button

var word: Word:
	set = _set_word


func _ready() -> void:
	_set_button_size()
	resized.connect(_set_button_size)

	button.pressed.connect(func():
		hint_input.text = word.hint
		hint_input.caret_column = word.hint.length()
		hint_display.visible = false
		hint_input.visible = true
		hint_input.grab_focus()
	)
	hint_input.text_submitted.connect(_on_hint_submitted)

func _set_button_size() -> void:
	button.size = size

func _set_word(value: Word) -> void:
	word = value
	word.did_update.connect(_rebuild_display)

	if not index_display:
		await  ready
	index_display.text = '%d:' % word.index
	_rebuild_display()

func _rebuild_display() -> void:
	for child in character_display.get_children():
		child.queue_free()

	for character in word.get_text():
		var new_label := Label.new()
		new_label.theme_type_variation = 'WordChars'
		new_label.text = character
		character_display.add_child(new_label)

func _on_hint_submitted(hint_text: String) -> void:
	hint_display.text = hint_text
	word.hint = hint_text
	hint_display.visible = true
	hint_input.visible = false
