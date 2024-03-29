extends Node2D

var actionName = "DefaultAction"

var is_inside_dropable = false;
var body_ref
var offset: Vector2
var initialPos : Vector2
var selected = false

func _ready():
	$Label.text = actionName

func _physics_process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25*delta)
	
func setAction(action):
	actionName = action
	$Label.text = action
	
func _on_area_2d_mouse_entered():
	start_hover_effect()
	
func _on_area_2d_mouse_exited():
	if not selected: #Keep the effect until the piece is dropped.
		finish_hover_effect()

func _on_area_2d_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("click"):
		selected = true

func _input(event):
	if event is InputEventMouseButton :
		if event.button_index and not event.pressed:
			selected = false;
			finish_hover_effect()

func start_hover_effect():
	GLOBAL.mouse_to_pointer()
	scale = Vector2(1.1, 1.1)
	
func finish_hover_effect():
	GLOBAL.mouse_to_normal()
	scale = Vector2(1.0, 1.0)
