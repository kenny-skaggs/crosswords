class_name DirectionSelector extends Control

signal did_select_right
signal did_select_down

@onready var down_button: BaseButton = %down_button
@onready var right_button: BaseButton = %right_button


func _ready() -> void:
	down_button.pressed.connect(did_select_down.emit)
	right_button.pressed.connect(did_select_right.emit)
