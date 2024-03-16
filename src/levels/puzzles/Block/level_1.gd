extends Node2D
#
#var movements = [null, null, null, null, null];
#
## Called when the node enters the scene tree for the first time.
#func _ready():
	#GLOBAL.freely_move_character = false;
	#GLOBAL.connect("playerStoppedMoving", _on_player_stop);
	#$DropSlot0.connect("movementAdded", _on_movement_added);
	#$DropSlot1.connect("movementAdded", _on_movement_added);
	#$DropSlot2.connect("movementAdded", _on_movement_added);
	#$DropSlot3.connect("movementAdded", _on_movement_added);
	#$DropSlot4.connect("movementAdded", _on_movement_added);
	#pass # Replace with function body.
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass;
#
#func _on_movement_added(texture, slot):
	## Obtén el nombre del archivo con extensión
	#var filename_with_extension = texture.resource_path.get_file()
	## Divide el nombre del archivo y la extensión
	#var split_filename = filename_with_extension.split(".")
	## El nombre del archivo sin extensión será la primera parte del resultado
	#var texture_name = split_filename[0]
	#var slot_number = int(slot.name.substr(slot.name.length() - 1));
#
	#match texture_name:
		#"Arrow":
			#movements[slot_number] = GLOBAL.DIR_DOWN;
		#"ArrowUp":
			#movements[slot_number] = GLOBAL.DIR_UP;
		#"ArrowLeft":
			#movements[slot_number] = GLOBAL.DIR_LEFT;
		#"ArrowRight":
			#movements[slot_number] = GLOBAL.DIR_RIGHT;
			#
	#print(movements);
#
#
#func _on_play_button_pressed():
	#GLOBAL.directionsUpdated.emit(movements);
#
#
#func _on_exit_body_entered(body):
	#print("ganaste");
	#
#func _on_player_stop():
	#print("perdiste");
