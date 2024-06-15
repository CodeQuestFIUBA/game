extends Node

signal directionsUpdated(new_directions);
signal playerStoppedMoving;

var regularMouse = load("res://assets/mouse/Kunai.png")
var dragMouse = load("res://assets/mouse/Drag.png")

# Movimiento del player, ejes de movimiento.
var axis : Vector2;
var freely_move_character = true;

const DIR_UP = "up";
const DIR_DOWN = "down";
const DIR_LEFT = "left";
const DIR_RIGHT = "right";


func _ready():
	Input.set_custom_mouse_cursor(regularMouse)

# Función para retornar la dirección pulsada.
func get_axis_from_input() -> Vector2:
	if freely_move_character:
		axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"));
		axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"));	
	return axis.normalized();

func get_axis_from_orders(node) -> Vector2:
	if node is CharacterBody2D && !freely_move_character:
			axis.x = int(node.current_direction == DIR_RIGHT) - int(node.current_direction == DIR_LEFT);
			axis.y = int(node.current_direction == DIR_DOWN) - int(node.current_direction == DIR_UP);
	return axis.normalized();

func mouse_to_normal():
	Input.set_custom_mouse_cursor(regularMouse)

func mouse_to_pointer():
	Input.set_custom_mouse_cursor(dragMouse)
