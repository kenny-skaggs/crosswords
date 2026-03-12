extends Control


const SelectorScene := preload("res://selector.tscn")
const TileScene := preload('res://tile.tscn')

@onready var tile_grid: GridContainer = %tile_grid
@onready var grid_container: CenterContainer = %grid_container

@onready var across_list: WordListDisplay = %across_list
@onready var down_list: WordListDisplay = %down_list


var active_selector: DirectionSelector
var hovered_tile: Tile

var focused_tile: Tile
var focused_direction: String

var grid_size := Vector2i(15, 15)
var tile_list: Array[Tile]

var puzzle: Puzzle


func _ready() -> void:
	tile_grid.resized.connect(func (): grid_container.custom_minimum_size.x = tile_grid.size.x)

	tile_grid.columns = grid_size.x

	for _x in grid_size.x:
		for _y in grid_size.y:
			var new_tile: Tile = TileScene.instantiate()
			new_tile.pressed.connect(_on_tile_needs_selector.bind(new_tile))
			new_tile.changed_availability.connect(_on_tile_availability_changed)

			tile_list.append(new_tile)
			tile_grid.add_child(new_tile)

	var x_index := 0
	var y_index := 0
	for tile in tile_list:
		if x_index < grid_size.x - 1:
			var right_tile := tile_list[x_index + 1 + (grid_size.x * y_index)]
			tile.next_right = right_tile
			right_tile.next_left = tile
		if y_index < grid_size.y - 1:
			var down_tile := tile_list[x_index + (grid_size.x * (y_index + 1))]
			tile.next_down = down_tile
			down_tile.next_up = tile

		x_index += 1
		if x_index == grid_size.x:
			x_index = 0
			y_index += 1

	_reset_tile_numbers()

func _on_tile_needs_selector(tile: Tile) -> void:
	if active_selector:
		active_selector.queue_free()
		hovered_tile = null

	hovered_tile = tile
	active_selector = SelectorScene.instantiate()
	active_selector.did_select_down.connect(
		_on_direction_selected.bind(tile, false)
	)
	active_selector.did_select_right.connect(
		_on_direction_selected.bind(tile, true)
	)
	add_child(active_selector)
	active_selector.global_position = tile.global_position

func _on_tile_remove_selector(tile: Tile) -> void:
	if hovered_tile == tile and active_selector:
		active_selector.queue_free()
		hovered_tile = null

func _on_direction_selected(tile: Tile, is_right: bool) -> void:
	active_selector.queue_free()
	_focus_cursor_on_tile(tile)

	focused_tile = tile
	focused_direction = 'next_right' if is_right else 'next_down'

func _input(event: InputEvent) -> void:
	if focused_tile and event.is_action_pressed('ui_left', true):
		_navigate_to(focused_tile.next_left, 'next_left')
	elif focused_tile and event.is_action_pressed('ui_right', true):
		_navigate_to(focused_tile.next_right, 'next_right')
	elif focused_tile and event.is_action_pressed('ui_up', true):
		_navigate_to(focused_tile.next_up, 'next_up')
	elif focused_tile and event.is_action_pressed('ui_down', true):
		_navigate_to(focused_tile.next_down, 'next_down')
	elif focused_tile and event.is_action_pressed('ui_cancel'):
		_focus_cursor_on_tile(null)
	elif event is InputEventKey and event.is_pressed():
		if not focused_tile:
			return

		var char_pressed := OS.get_keycode_string(event.key_label)
		var char_len := char_pressed.length()
		var advance_cursor := char_len == 1 or event.is_action_pressed('character_skip')
		if char_len == 1:
			focused_tile.set_char(char_pressed)
		elif event.is_action_pressed('ui_text_backspace'):
			focused_tile.set_char('')
			advance_cursor = false

		if advance_cursor:
			var next_tile: Tile = focused_tile[focused_direction]
			if next_tile and next_tile.is_part_of_word():
				_focus_cursor_on_tile(next_tile)
			else:
				_focus_cursor_on_tile(null)

func _navigate_to(tile: Tile, movement_direction: String) -> void:
	if not tile:
		_focus_cursor_on_tile(null)
		return
	elif not tile.is_part_of_word():
		_navigate_to(tile[movement_direction], movement_direction)
		return

	_focus_cursor_on_tile(tile)

func _reset_tile_numbers() -> void:
	var across_word_list: Array[Word]
	var down_word_list: Array[Word]

	var current_number := 1
	for tile in tile_list:
		if tile.disabled:
			tile.set_number_display('')
			continue

		var is_start_of_word := false
		var up_tile := tile.next_up
		var left_tile := tile.next_left
		if not up_tile or not up_tile.is_part_of_word():
			var new_word := _build_word(tile, 'next_down')
			down_word_list.append(new_word)
			new_word.index = current_number
			is_start_of_word = true
		if not left_tile or not left_tile.is_part_of_word():
			var new_word := _build_word(tile, 'next_right')
			across_word_list.append(new_word)
			new_word.index = current_number
			is_start_of_word = true

		if is_start_of_word:
			tile.set_number_display(str(current_number))
			current_number += 1
		else:
			tile.set_number_display('')

	across_list.word_list = across_word_list
	down_list.word_list = down_word_list

func _on_tile_availability_changed() -> void:
	_reset_tile_numbers()

func _build_word(starting_tile: Tile, direction_prop: String) -> Word:
	var tile_set: Array[Tile]
	var next_tile := starting_tile
	while next_tile and next_tile.is_part_of_word():
		tile_set.append(next_tile)
		next_tile = next_tile[direction_prop]

	var new_word := Word.new(tile_set)
	return new_word

func _focus_cursor_on_tile(tile: Tile) -> void:
	if focused_tile:
		focused_tile.set_focused(false)

	focused_tile = tile
	if focused_tile:
		focused_tile.set_focused(true)


# todo:
#	should show direction when cursor is active
#			and maybe shift (and/or ui button) to change directions
#	need to force submit on any open text boxes when opening a new one
# 	backspace should jump backwards one too
