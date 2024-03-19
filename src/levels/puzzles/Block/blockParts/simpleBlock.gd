extends Control

var actionName = "DefaultAction"

var draggable = false
var is_inside_dropable = false;
var body_ref
var offset: Vector2
var initialPos : Vector2

func _ready():
	$Label.text = actionName
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass;

func setAction(action):
	actionName = action
	$Label.text = action
	
func _on_area_2d_mouse_entered():
	if not GlobalBlockTracking.is_dragging:
		draggable=true;
		GLOBAL.mouse_to_pointer()
		scale = Vector2(1.1, 1.1)
	
func _on_area_2d_mouse_exited():
	if not GlobalBlockTracking.is_dragging:
		draggable=false;
		GLOBAL.mouse_to_normal()
		scale = Vector2(1.0, 1.0)

func get_drag_data(position : Vector2):
	var data={}
	data
