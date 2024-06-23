extends Node2D

@onready var spinner = $TextureRect;
var move_spinner = 0;
const speed = 180;

func _ready():
	GLOBAL.connect("startLoading", start_spinner);
	GLOBAL.connect("stopLoading", stop_spinner);

func _process(delta):
	spinner.rotation_degrees += delta * speed * move_spinner;

func start_spinner():
	move_spinner = 1;

func stop_spinner():
	move_spinner = 0;
