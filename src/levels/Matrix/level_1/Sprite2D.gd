extends Sprite2D

signal keyArrivedDestination;

var TILE_SIZE = 16;
var SPEED = 100;

var is_moving = false;
var destination: Vector2 = self.global_position;

func _ready():
	self.visible = false;
	
func _process(delta):
	if is_moving:
		self.global_position = self.global_position.move_toward(destination, delta*SPEED);
		if self.global_position == destination:
			is_moving = false;
			emit_signal("keyArrivedDestination");

func show_key(coords: Vector2i):
	self.global_position = Vector2(
		self.global_position.x + coords.x * TILE_SIZE,
		self.global_position.y + coords.y * TILE_SIZE,
	);
	self.visible = true;
		
func move_to(position: Marker2D):
	destination = position.global_position;
	is_moving = true;
	
	
