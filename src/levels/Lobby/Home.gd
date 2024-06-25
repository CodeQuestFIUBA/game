extends Node2D

@onready var playerContainer = $PlayerContainer/CollisionPolygon2D;
@onready var login = $Login;
var containPlayer = true;

func _process (delta):
	#if (ApiService.token):
		playerContainer.disabled = true;
		login.visible = false;
		

func _on_player_detector_body_entered(body: Node2D) -> void:
	RoomEvents.room_entered.emit(self)
