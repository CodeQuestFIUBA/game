extends Node2D

var actionName = "DefaultAction"

var draggable = false
var is_inside_dropable = false;

var regularMouse = load("res://assets/mouse/Kunai.png")
var dragMouse = load("res://assets/mouse/Drag.png")


func _ready():
	$Label.text = actionName

func setAction(action):
	actionName = action
	$Label.text = action
	
func _on_area_2d_mouse_entered():
#	if not GlobalBlockTracking.is_dragging:
#		draggable=true;
	Input.set_custom_mouse_cursor(dragMouse)
	scale = Vector2(1.1, 1.1)
	
func _on_area_2d_mouse_exited():
#	if not GlobalBlockTracking.is_dragging:
#		draggable=true;
	Input.set_custom_mouse_cursor(regularMouse)
	scale = Vector2(1.0, 1.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
