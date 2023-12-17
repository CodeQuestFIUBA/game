extends CharacterBody2D

const SPEED = 100.0
const INITIAL_POS_X = 144
const INITIAL_POS_Y = 81

signal doorOpened()

func update_animations():
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

func _physics_process(delta):
	var ide_nodes = get_tree().get_nodes_in_group("ide")
	if ide_nodes.size() > 0:
		var ide = ide_nodes[0] as Control
		if ide.visible:
			return
	update_animations();
	
	var movement = GLOBAL.get_axis();
	velocity.x = movement.x * SPEED
	velocity.y = movement.y * SPEED
	move_and_slide()

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
	elif arg.down == 1:
		$AnimationPlayer.play('idle_down');
	elif arg.up == 1:
		$AnimationPlayer.play('idle_up');
	elif arg.right == 1:
		$AnimationPlayer.play('idle_right');
	elif arg.left == 1:
		$AnimationPlayer.play('idle_left');


func move_player(arg):
	#update_animations_automatically(arg);
	var movement = GLOBAL.get_axis();
	velocity.x = (movement.x + arg.right - arg.left) * SPEED
	velocity.y = (movement.y + arg.down - arg.up) * SPEED
	move_and_slide()
