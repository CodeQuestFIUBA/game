extends Node2D

@onready var playerContainer = $PlayerContainer/CollisionPolygon2D;
@onready var login = $Login;
@onready var register = $Register;
var containPlayer = true;
var registerActive = false;
var loginActive = true;

func _ready():
	login._on_button_pressed()

func _process (delta):
	if !!Session.token:
		registerActive = false
		loginActive = false
	playerContainer.disabled = true;
	login.visible = !Session.token && !registerActive;
	register.visible = !Session.token && !loginActive;
		

func _on_player_detector_body_entered(body: Node2D) -> void:
	RoomEvents.room_entered.emit(self)


func _on_button_register_pressed():
	registerActive = true
	loginActive = false
	login.visible = false
	register.visible = true


func _on_texture_button_pressed():
	registerActive = false
	loginActive = true
	login.visible = true
	register.visible = false
