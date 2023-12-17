extends Node


@onready var text_bons_scene = preload("res://components/TextBox.tscn")
signal signalCloseDialog()


var dialog_lines: Array[String] = []
var current_line_index = 0

var text_box
var text_box_position: Vector2

var is_dialog_active = false
var can_advanace_line = false
var close_last_text = false


func start_dialog(position: Vector2, lines: Array[String], closeLastDialog: bool = false):
	if is_dialog_active:
		return
	close_last_text = closeLastDialog
	dialog_lines = lines
	text_box_position = position
	_show_text_box()
	
	is_dialog_active = true
	
func reset_dialog(position: Vector2, lines: Array[String], closeLastDialog: bool = false):
	close_last_text = closeLastDialog
	text_box.queue_free()
	current_line_index +=1
	is_dialog_active = false
	current_line_index = 0
	can_advanace_line = false
	is_dialog_active = false
	current_line_index = 0
	dialog_lines = lines
	_show_text_box()
	is_dialog_active = true
	
func _show_text_box():
	text_box = text_bons_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	get_tree().root.add_child(text_box)
	text_box.global_position = text_box_position
	text_box.display_text(dialog_lines[current_line_index])
	can_advanace_line = false


func _on_text_box_finished_displaying():
	can_advanace_line = true
	

func _unhandled_input(event):
	if (
		(
			event.is_action_pressed("advance_dialog") ||
			(
				is_dialog_active &&
				can_advanace_line
			)
		) &&
		(
			dialog_lines.size() - 1 > current_line_index ||
			close_last_text
		)
	):
		text_box.queue_free()
		
		current_line_index +=1
		if current_line_index >= dialog_lines.size():
			is_dialog_active = false
			current_line_index = 0
			_on_close_dialog()
			return
			
		_show_text_box()
		
		
func _on_close_dialog():
	emit_signal("signalCloseDialog")
