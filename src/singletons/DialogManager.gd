extends Node

@onready var text_box_scene = preload("res://components/TextBox.tscn")
signal signalCloseDialog()

var dialog_lines: Array[String] = []

var text_box
var text_box_position: Vector2

var is_dialog_active = false
var can_advanace_line = false
var defaultOptions = {
	'auto_play_next_text': true,
	'auto_play_time': 0.5,
	'close_by_signal': false
}
var waitNext = false
var dialog_options = defaultOptions
var press_next_dialog = false
var lastId

func close_dialog():
	var close = press_next_dialog && dialog_options['close_by_signal']
	var auto_close = can_advanace_line && dialog_options['auto_play_next_text']
	if waitNext && !close:
		return
	if (auto_close || close):
		if !close:
			waitNext = true
			var timer = get_tree().create_timer(dialog_options['auto_play_time'])
			lastId = timer
			await timer.timeout
			if timer != lastId:
				return
		waitNext = false
		can_advanace_line = false
		press_next_dialog = false
		if is_instance_valid(text_box): text_box.queue_free()
		
		if dialog_lines.size() == 0:
			is_dialog_active = false
			_on_close_dialog()
			return
		_show_text_box()


func initialize_options(options = null):
	if options == null:
		return
	dialog_options = options
	for option in defaultOptions:
		if !dialog_options.has(option):
			dialog_options[option] = defaultOptions[option]


func start_dialog(position: Vector2, lines: Array[String], options = defaultOptions):
	if is_dialog_active:
		return
	is_dialog_active = false
	can_advanace_line = false
	var waitNext = false
	press_next_dialog = false
	initialize_options(options)
	dialog_lines = lines.duplicate(true)
	text_box_position = position
	_show_text_box()
	is_dialog_active = true


func reset_dialog(position: Vector2, lines: Array[String], options = defaultOptions):
	initialize_options(options)
	if is_instance_valid(text_box): text_box.queue_free()
	is_dialog_active = false
	can_advanace_line = false
	is_dialog_active = false
	dialog_lines = lines.duplicate(true)
	_show_text_box()
	is_dialog_active = true


func _show_text_box():
	text_box = text_box_scene.instantiate()
	add_child(text_box)
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	text_box.global_position = text_box_position
	text_box.display_text(dialog_lines.pop_front())
	can_advanace_line = false


func _on_text_box_finished_displaying():
	can_advanace_line = true
	close_dialog()


func _unhandled_input(event):
	press_next_dialog = event.is_action_pressed("advance_dialog")
	close_dialog()


func _on_close_dialog():
	emit_signal("signalCloseDialog")

