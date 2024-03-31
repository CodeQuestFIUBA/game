extends CharacterBody2D

signal npcArrived
signal npcFinishAttack

@onready var npc_texture: Sprite2D = $Sprite2D

const SPEED = 50.00;

var autoplay_enabled = false;
var current_state = IDLE;
var input_enabled = true;

var current_direction = null;
var last_direction = null;
var next_positions = [];
var in_attack = false

var dialog_position = Vector2(0, 0);
var phrases_index = 0;
var phrases: Array[String] = [];

enum {
	IDLE, 
	NEW_DIR,
	MOVING
}
	
func _ready():
	set_process_input(true);	
	
func  _physics_process(delta):
	if in_attack:
		return
	if next_positions.size() == 0:
		$AnimationPlayer.play('idle_down');
		current_state = IDLE;
	if next_positions.size() > 0:
		var movement = _get_next_move(next_positions[0]);
		_update_direction(movement);
		_update_animations();
		current_state = MOVING;
		velocity.x = movement.x * SPEED;
		velocity.y = movement.y * SPEED;
		move_and_slide();
		if _arrived_destination(next_positions[0]): 
			next_positions.pop_front();
			current_state = NEW_DIR;
			if next_positions.size() == 0:
				_send_arrived()

func _send_arrived():
	emit_signal("npcArrived")

func _input_event(viewport, event, shape_idx):
	if phrases.is_empty() || autoplay_enabled: return;
	if event is InputEventMouseButton and DialogManager:
		var mouse_button_event = event as InputEventMouseButton
		if mouse_button_event.pressed and mouse_button_event.button_index == MOUSE_BUTTON_LEFT:
			_show_new_dialog();
			
func _show_new_dialog():
	if phrases_index ==	0:
		DialogManager.start_dialog(dialog_position, [phrases[phrases_index]]);
	else: 
		DialogManager.reset_dialog(dialog_position, [phrases[phrases_index]], true);
	phrases_index = (phrases_index + 1) % phrases.size();

func _update_animations():
	if in_attack:
		return
	if current_state == IDLE || current_state == NEW_DIR:
		match last_direction:
			GLOBAL.DIR_UP:
				$AnimationPlayer.play('idle_up');
			GLOBAL.DIR_LEFT:
				$AnimationPlayer.play('idle_left');
			GLOBAL.DIR_RIGHT:
				$AnimationPlayer.play('idle_right');
			_:
				$AnimationPlayer.play('idle_down');
	else:
		match current_direction:
			GLOBAL.DIR_DOWN:
				$AnimationPlayer.play('move_down');
			GLOBAL.DIR_UP:
				$AnimationPlayer.play('move_up');
			GLOBAL.DIR_LEFT:
				$AnimationPlayer.play('move_left');
			GLOBAL.DIR_RIGHT:
				$AnimationPlayer.play('move_right');
				
func _get_next_move(destination: Vector2):
	var dir_x = destination.x - position.x;
	var dir_y = destination.y - position.y; 
	var angle = atan2(dir_y, dir_x);
	
	if angle < 0:
		angle += 2 * PI
	
	return Vector2(cos(angle), sin(angle));
	
func _update_direction(movement: Vector2):
	last_direction = current_direction;
	if abs(movement.y) >= abs(movement.x):
		if movement.y < 0: current_direction = GLOBAL.DIR_UP;
		else: current_direction = GLOBAL.DIR_DOWN;
	else:
		if movement.x > 0: current_direction = GLOBAL.DIR_RIGHT;
		else: current_direction = GLOBAL.DIR_LEFT;
	
func _arrived_destination(destination):
	return sqrt(pow(destination.x-position.x, 2) + pow(destination.y-position.y, 2)) < 0.5
	
# --------------------------------- METODOS PUBLICOS ----------------------------------------

# Actualiza la lista de puntos por los que tiene que pasar el npc	
# El npc comienza a moverse apenas se llama a este metodo
func update_destination(destinations: Array[Vector2]):
	next_positions = destinations.duplicate(true);
	
# Actualiza las frases del npc
# Si autiplay esta activado el dialogo se ejecuta solo
# Caso contrario una nueva frase aparece con cada click sobre el npc
func update_phrases(new_phrases: Array[String], dialog_pos: Vector2, autoplay:bool = false, options = null):
	dialog_position = dialog_pos;
	autoplay_enabled = autoplay;
	phrases = new_phrases.duplicate(true);
	phrases_index = 0;
	if (autoplay_enabled):
		DialogManager.start_dialog(dialog_position, phrases, options);


func update_texture(newTexture):
	npc_texture.texture = ResourceLoader.load(newTexture)

# direction puede ser: up, left, right, down
func attack(direction: String):
	match direction:
		'up':
			in_attack = true
			$AnimationPlayer.play('attack_up')
		'down':
			in_attack = true
			$AnimationPlayer.play('attack_down')
		'left':
			in_attack = true
			$AnimationPlayer.play('attack_left')
		'right':
			in_attack = true
			$AnimationPlayer.play('attack_right')


func _animation_finished(anim_name):
	if anim_name == 'attack_left' || anim_name == 'attack_right' || anim_name == 'attack_up' || anim_name == 'attack_down':
		in_attack = false
		emit_signal('npcFinishAttack')

