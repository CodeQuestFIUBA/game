extends Node2D
signal level_completed(thisLevel)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_door_opened():
	print(self.name + " completed")
	level_completed.emit(self.name)
	get_tree().change_scene_to_file("res://levels/Level2.tscn")
