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
	update_animations();
	
	var movement = GLOBAL.get_axis();
	velocity.x = movement.x * SPEED
	velocity.y = movement.y * SPEED
	move_and_slide()

func _on_door_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if (body.name == "Player"):
		doorOpened.emit()
