extends CharacterBody2D

var positions = []
var mooving = false;
var followCaracter = false;
const SPEED = 25.00;
var actual_target = 0;
signal onArrival(pos : int);
@onready var originalSprite = load("res://sprites/boat.png")
@onready var spriteWithNinja = load("res://sprites/boatWithCaracter.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if not mooving or positions.size() == 0 :
		return;
	_updateTarget();
	_set_velocity();

func _set_velocity():
	var movement =  _get_next_move(positions[actual_target]);
	velocity.x = movement.x * SPEED;
	velocity.y = movement.y * SPEED;
	move_and_slide()

func _updateTarget():
	if (_arrived_destination(positions[actual_target])):
		onArrival.emit(actual_target)
		actual_target = 0 if (actual_target == positions.size()-1) else actual_target+1
	
func _get_next_move(destination: Vector2):
	var dir_x = destination.x - position.x;
	var dir_y = destination.y - position.y;
	var angle = atan2(dir_y, dir_x);
	
	if angle < 0:
		angle += 2 * PI
	return Vector2(cos(angle), sin(angle));
	
func _arrived_destination(destination):
	return sqrt(pow(destination.x-position.x, 2) + pow(destination.y-position.y, 2)) < 0.5

# Publicas
func setPositions (_pos : Array):
	print(_pos)
	positions = _pos
	
func stop ():
	mooving = false;

func start():
	mooving = true;

func put_ninja_on_board():
	print("Changing boat sprite")
	$Sprite2D.texture = spriteWithNinja
func remove_ninja_on_board():
	$Sprite2D.texture = originalSprite
