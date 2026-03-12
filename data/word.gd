class_name Word extends Resource

signal did_update

var _tile_set: Array[Tile]
@export var index: int
@export var hint: String

@export var answer: String:
	get = get_text


func _init(tile_set: Array[Tile]) -> void:
	_tile_set = tile_set
	for tile in _tile_set:
		tile.changed_contents.connect(did_update.emit)

func get_text() -> String:
	var result := ""
	for tile in _tile_set:
		var character := tile.get_char()
		result += "_" if character.is_empty() else character

	return result
