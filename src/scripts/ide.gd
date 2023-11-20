extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _process(delta):
	pass


func _on_button_clear_pressed():
	var code_edit_nodes = get_tree().get_nodes_in_group("codeEdit")
	if code_edit_nodes.size() > 0:
		var code_edit = code_edit_nodes[0] as CodeEdit
		code_edit.text = ''


func _on_button_execute_pressed():
	var code_edit_nodes = get_tree().get_nodes_in_group("codeEdit")
	if code_edit_nodes.size() > 0:
		var code_edit = code_edit_nodes[0] as CodeEdit
		var text = code_edit.text
		print(text)
	


func _on_button_close_pressed():
	self.visible = false
