class_name WordListDisplay extends VFlowContainer

const WordDisplayScene := preload('res://construction/word_display.tscn')


var word_list: Array[Word]:
	set = _create_word_display_elements


func _create_word_display_elements(words: Array[Word]) -> void:
	word_list = words

	for child in get_children():
		child.queue_free()

	for word in word_list:
		var word_display: WordDisplay = WordDisplayScene.instantiate()
		word_display.word = word
		add_child(word_display)
