extends CharacterBody2D

const SPEED = 100.00
const AUTO_SPEED = 1
const INITIAL_POS_X = 144
const INITIAL_POS_Y = 81
var directions = []
var is_moving = false;
var stopped_moving = false;
var last_direction = null;
var current_direction = null;

signal doorOpened();

func _ready():
	GLOBAL.connect("directionsUpdated", _on_directions_update);

func update_animations():
	if GLOBAL.freely_move_character:	
		if Input.is_action_pressed('ui_down'):
			$AnimationPlayer.play('move_down');
		elif Input.is_action_pressed('ui_up'):
			$AnimationPlayer.play('move_up');
		elif Input.is_action_pressed('ui_left'):
			$AnimationPlayer.play('move_left');
		elif Input.is_action_pressed('ui_right'):
			$AnimationPlayer.play('move_right');
		elif Input.is_action_just_released('ui_down'):
			$AnimationPlayer.play('idle_down');
		elif Input.is_action_just_released('ui_up'):
			$AnimationPlayer.play('idle_up');
		elif Input.is_action_just_released('ui_right'):
			$AnimationPlayer.play('idle_right');
		elif Input.is_action_just_released('ui_left'):
			$AnimationPlayer.play('idle_left');
	elif stopped_moving:
		match last_direction:
			GLOBAL.DIR_DOWN:
				$AnimationPlayer.play('idle_down');
			GLOBAL.DIR_UP:
				$AnimationPlayer.play('idle_up');
			GLOBAL.DIR_LEFT:
				$AnimationPlayer.play('idle_left');
			GLOBAL.DIR_RIGHT:
				$AnimationPlayer.play('idle_right');
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
		

func _physics_process(delta):
	var ide_nodes = get_tree().get_nodes_in_group("ideContainer")
	if ide_nodes.size() > 0:
		var ide = ide_nodes[0] as Control
		if ide.visible:
			return
	update_animations();
	
	if GLOBAL.freely_move_character:
		move_player_using_keys();
	else:
		move_player_with_orders();

func _on_door_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if (body.name == "Player"):
		doorOpened.emit()


func update_animations_automatically(arg):
	if arg.down == 1:
		$AnimationPlayer.play('move_down');
	elif arg.up == 1:
		$AnimationPlayer.play('move_up');
	elif arg.left == 1:
		$AnimationPlayer.play('move_left');
	elif arg.right == 1:
		$AnimationPlayer.play('move_right');
	elif arg.down == -1:
		$AnimationPlayer.play('idle_down');
	elif arg.up == -1:
		$AnimationPlayer.play('idle_up');
	elif arg.right == -1:
		$AnimationPlayer.play('idle_right');
	elif arg.left == -1:
		$AnimationPlayer.play('idle_left');


func move_player(arg):
	update_animations_automatically(arg);
	var movement = GLOBAL.get_axis_from_input();
	velocity.x = (movement.x + arg.right - arg.left) * SPEED
	velocity.y = (movement.y + arg.down - arg.up) * SPEED
	move_and_slide();
		
func move_player_using_keys():
	var movement = GLOBAL.get_axis_from_input();
	velocity.x = movement.x * SPEED;
	velocity.y = movement.y * SPEED;
	move_and_slide();
	
func move_player_with_orders():
	if stopped_moving: return;
	
	var movement = GLOBAL.get_axis_from_orders(self)

	if !current_direction:
		if directions.size() > 0:
			current_direction = directions[0]
			directions.remove_at(0)
		elif is_moving:
			stopped_moving = true;
			GLOBAL.playerStoppedMoving.emit();

	if current_direction:
		var collision = move_and_collide(Vector2(
			movement.x * AUTO_SPEED, 
			movement.y * AUTO_SPEED
		))
		if collision:
			last_direction = current_direction;
			if directions.size() > 0:
				current_direction = directions[0]
				directions.remove_at(0)
			else:
				current_direction = null

func _on_directions_update(new_directions):
	is_moving = true;
	directions = new_directions
