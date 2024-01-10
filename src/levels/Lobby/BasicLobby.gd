extends Node2D

func _on_player_detector_body_entered(body):
	RoomEvents.room_entered.emit(self)


func _on_left_door_body_entered(body):
	get_tree().change_scene_to_file("res://levels/Demo/Demo.tscn")


func _on_up_door_body_entered(body):
	get_tree().change_scene_to_file("res://levels/puzzles/pathPainter/level_1.tscn")
