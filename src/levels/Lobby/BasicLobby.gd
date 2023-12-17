extends Node2D

func _on_player_detector_body_entered(body):
	RoomEvents.room_entered.emit(self)
