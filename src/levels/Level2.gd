extends Node2D
signal level_completed(thisLevel)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var open_ide_press = Input.get_action_strength("show_ide")
	if open_ide_press == 1:
		show_ide()

func _on_player_door_opened():
	print(self.name + " completed")
	level_completed.emit(self.name)
	get_tree().change_scene_to_file("res://levels/Level1.tscn")


func show_ide():
	var ide_nodes = get_tree().get_nodes_in_group("ide")
	if ide_nodes.size() > 0:
		var ide = ide_nodes[0] as Control
		if ide.visible == false:
			ide.visible = true
