extends TileMap

@onready var timer = get_node("../Timer");

signal matrixAnimationFinished(coords);

var params;
var result;
var expected_result;

var coords_array: Array[Vector2i] = [];
var current: Vector2i; 
var previous: Vector2i; 

var markerLayer = 6;
var markerTextureCoord = Vector2i(6, 1);
var markerTextureAlt = 2;

func _ready():
	get_parent().connect("coordinatesReady", on_coordinates_update)
			
func updateMarker(coords: Vector2i, previousCoords: Vector2i):
	erase_cell(markerLayer, previousCoords);
	set_cell(markerLayer, coords, 1, markerTextureCoord, markerTextureAlt);
	
func on_coordinates_update(coords, params, new_result, new_expected_result):
	if coords.size() == 0:
		print("Error");
		return;
		
	if current: 
		previous = current 
	else: 
		previous = Vector2i(-1, -1);
	params = params;
	result = new_result;
	expected_result = new_expected_result;
	coords_array = coords;
	current = coords_array.pop_front();
	updateMarker(current, previous);
	timer.start();

func _on_timer_timeout():
	if coords_array.is_empty():
		timer.stop();
		_validate_success();
		return;
	previous = current;	
	current = coords_array.pop_front();
	updateMarker(current, previous);
	
func _validate_success():
	if result.x == expected_result.x && result.y == expected_result.y:
		emit_signal("matrixAnimationFinished", current);
	
