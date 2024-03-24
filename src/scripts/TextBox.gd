extends MarginContainer

@onready var label = $MarginContainer/Label
@onready var timer = $LetterDisplayTimer

const MAX_WIDTH = 256

var text = ""
var letter_index = 0

var letter_time = 0.03
var space_time = 0.06
var puntuaction_time = 0.2
const MIN_WIDTH = 21

signal finished_displaying()

func _ready():
	pass

# Called when the node enters the scene tree for the first time.
func display_text(text_to_display: String):
	if !label:
		return
	
	text = text_to_display
	label.text = text_to_display
	print(label.get_minimum_size())
	if text.length() > MIN_WIDTH: 
		await resized
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	
	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		if text.length() > MIN_WIDTH: 
			await resized
			await resized
		custom_minimum_size.y = size.y
	
	#print(text_to_display, global_position)
	
	label.text = ""
	_display_letter()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _display_letter():
	label.text += text[letter_index]
	letter_index +=1
	if letter_index >= text.length():
		finished_displaying.emit()
		return
		
	match text[letter_index]:
		"!", ".", ",", "?":
			timer.start(puntuaction_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(letter_time)


func _on_letter_display_timer_timeout():
	_display_letter()
