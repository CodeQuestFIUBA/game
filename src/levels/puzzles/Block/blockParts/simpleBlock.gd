class_name SimpleBlock
extends Node2D
var actionName = "DefaultAction"

var selected = false;
var rest_pos : Vector2
var body_ref : StaticBody2D = null;
var is_new = true;
var is_selectable = true;

func _ready():
	$Label.text = actionName
	rest_pos = global_position

func _physics_process(delta):
	if selected:
		if is_new: #Drops a clone in the spawn.
			insert_replacement()
		global_position = lerp(global_position, get_global_mouse_position(), 25*delta)
	else :
		global_position = lerp(global_position, rest_pos, 10*delta)

func setAction(action):
	actionName = action
	$Label.text = action

func _on_area_2d_mouse_entered():
	if (is_selectable):
		start_hover_effect()

func _on_area_2d_mouse_exited():
	if not selected: #Keep the effect until the piece is dropped.
		finish_hover_effect()

func _on_area_2d_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("click") and not GlobalBlockTracking.is_dragging and is_selectable:
		selected = true
		GlobalBlockTracking.is_dragging = true;

func _input(event):
	if event is InputEventMouseButton and selected:
		if event.button_index and not event.pressed:
			selected = false;
			GlobalBlockTracking.is_dragging = false;
			finish_hover_effect()
			if (body_ref != null):
				rest_pos = body_ref.get_drop_position()
				body_ref.handle_drop(self)

func start_hover_effect():
	GLOBAL.mouse_to_pointer()
	scale = Vector2(1.1, 1.1)

func finish_hover_effect():
	GLOBAL.mouse_to_normal()
	scale = Vector2(1.0, 1.0)

func _on_area_2d_body_entered(body : StaticBody2D):
	body_ref = body

func _on_area_2d_body_exited(body : StaticBody2D):
	#body_ref = null;
	pass;

# Generate a new node with the same carac. as my self
func insert_replacement():
	is_new = false;
	var new_instance = self.duplicate()
	new_instance.actionName = actionName
	get_parent().add_child(new_instance)
