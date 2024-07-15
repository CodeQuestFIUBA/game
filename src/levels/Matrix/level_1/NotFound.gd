extends Sprite2D

signal keyArrivedDestination;

var TILE_SIZE = 16;
var SPEED = 100;

var is_moving = false;
var destination: Vector2 = self.global_position;
var initial_pos

func _ready():
	self.visible = false;
	initial_pos = self.global_position
	
func show_element(coords: Vector2i):
	self.global_position = Vector2(
		self.global_position.x + coords.x * TILE_SIZE,
		self.global_position.y + coords.y * TILE_SIZE,
	);
	self.visible = true;
		
func hide_element():
	self.visible = false;
	self.global_position = initial_pos
