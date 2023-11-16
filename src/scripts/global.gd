extends Node

const MAX_LIFE: int = 100;
var score: int = 0;

# Movimiento del player, ejes de movimiento.
var axis : Vector2;

# Función para retornar la dirección pulsada.
func get_axis() -> Vector2:
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"));
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"));
	return axis.normalized();
