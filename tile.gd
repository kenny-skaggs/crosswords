class_name Tile extends Button

signal changed_availability
signal changed_contents

signal mouse_did_leave
signal mouse_did_enter

var _char: String
@onready var label: Label = %Label
@onready var cursor_animation: AnimationPlayer = %cursor_animation
@onready var number_label: Label = %number_label
@onready var mouse_detection: Area2D = %mouse_detection

var next_right: Tile
var next_down: Tile
var next_up: Tile
var next_left: Tile


func _ready() -> void:
	mouse_detection.mouse_exited.connect(mouse_did_leave.emit)
	mouse_detection.mouse_entered.connect(mouse_did_enter.emit)

func set_focused(focused: bool) -> void:
	if focused:
		cursor_animation.play('blink')
	else:
		cursor_animation.stop()

func set_char(value: String) -> void:
	_char = value.to_upper()
	label.text = _char
	changed_contents.emit()

func get_char() -> String:
	return _char

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed('secondary_select'):
		disabled = !disabled
		changed_availability.emit()

		label.visible = !disabled

func set_number_display(value: String) -> void:
	number_label.text = value

func is_part_of_word() -> bool:
	return not disabled
