extends Node2D

@onready var whipMaster = $WhipMaster
@onready var ninjakuMaster = $NinjakuMaster
@onready var katanaMaster = $katanaMaster
@onready var saiMaster = $SaiMaster
@onready var master = $Master
@onready var player = $Player
@onready var ide = $CanvasLayer/IDE

var playerSteps: Array[Vector2] = [ Vector2(86,180), Vector2(208,180) ]
var whipMasterSteps: Array[Vector2] = [ Vector2(288,78), Vector2(288,128) ]
var ninjakuMasterSteps: Array[Vector2] = [ Vector2(240,103), Vector2(240,128) ]
var saiMasterSteps: Array[Vector2] = [ Vector2(70,128), Vector2(120,128) ]
var katanaMasterSteps: Array[Vector2] = [ Vector2(178,128) ]
var alternativeKatanaMasterSteps: Array[Vector2] = [ Vector2(70,128), Vector2(70,103), Vector2(178,103), Vector2(178,128)]
var firstTablePosition: Array[Vector2] = [Vector2(120,170)]
var secondTablePosition: Array[Vector2] = [Vector2(178,170)]
var thirdTablePosition: Array[Vector2] = [Vector2(240,170)]
var fourthTablePosition: Array[Vector2] = [Vector2(288,170)]
var finalPosition: Array[Vector2] = [Vector2(208,180)]
const VEN: String = 'VEN'
const ESPERA: String = 'ESPERA'
var masterPhrases = {
	'katana': {
		'initial': {
			'message': ['Busca la Katana'],
			'position': Vector2(35,78)
		},
		'finalOk': {
			'message': ['Muy bien!'],
			'position': Vector2(288,128)
		},
		'finalError': {
			'message': ['Lo siento, esa no es la Kantana'],
			'position': Vector2(35,78)
		}
	},
	'sai': {
		'initial': {
			'message': ['Busca el Sai'],
			'position': Vector2(35,155)
		},
		'finalOk': {
			'message': ['Muy bien!'],
			'position': Vector2(178,128)
		},
		'finalError': {
			'message': ['Lo siento, ese no es el Sai'],
			'position': Vector2(35,155)
		}
	},
	'ninjaku': {
		'initial': {
			'message': ['Busca el Ninjaku'],
			'position': Vector2(35,103)
		},
		'finalOk': {
			'message': ['Muy bien!'],
			'position': Vector2(240,128)
		},
		'finalError': {
			'message': ['Lo siento, esa no es el Ninjaku'],
			'position': Vector2(35,103)
		}
	},
	'whip': {
		'initial': {
			'message': ['Busca el Whip'],
			'position': Vector2(35,78)
		},
		'finalOk': {
			'message': ['Muy bien!'],
			'position': Vector2(288,128)
		},
		'finalError': {
			'message': ['Lo siento, esa no es el Whip'],
			'position': Vector2(35,78)
		}
	}
}
var movedSaiMaster = false
var lastAction = ''

var result = {}

const TEST_RESULT = {
	'whip': ['ESPERA', 'ESPERA', 'ESPERA', 'VEN'],
	'sai': ['VEN', 'ESPERA', 'ESPERA', 'ESPERA'],
	'katana': ['ESPERA', 'VEN', 'ESPERA', 'ESPERA'],
	'ninjaku': ['ESPERA', 'ESPERA', 'VEN', 'ESPERA']
}

var orderResult: Array[String] = []
var gunsByTable: Array[String] = ['sai', 'katana', 'ninjaku', 'whip']

enum {
	INITIAL,
	FINAL_OK,
	FINAL_ERROR
}

enum {
	PLAYER_INIT,
	PLAYER_MOVING,
	MASTER_MOVING,
	PLAYER_CALL_MASTER,
	PLAYER_WAIT_MASTER
}

enum {
	PLAYER_ORIGIN,
	IN_FIRST_TABLE,
	IN_SECOND_TABLE,
	IN_THIRD_TABLE,
	IN_FOURTY_TABLE
}


enum {
	INIT_DIALOG,
	FIRST_DIALOG_MASTER,
	FIRST_GUN_MASTER,
	SECOND_GUN_MASTER,
	THIRD_GUN_MASTER,
	FOURTH_GUN_MASTER,
	SECOND_DIALOG_MASTER
}


enum {
	PLAYER_CALL_INIT,
	PLAYER_SEND_MESSAGE
}


enum {
	MESSAGE_MASTER,
	MOVE_PLAYER
}

var init_state_player = MESSAGE_MASTER
var dialogPhases = true
var masterMoving = PLAYER_CALL_INIT
var actualDialogStates = INIT_DIALOG
var playerWaitting = false
var actualState = PLAYER_INIT
var playerState = PLAYER_ORIGIN
var firstCall = true
var error = false

func test_result():
	result[orderResult[0]] = TEST_RESULT[orderResult[0]].duplicate(true)
	result[orderResult[1]] = TEST_RESULT[orderResult[1]].duplicate(true)
	result[orderResult[2]] = TEST_RESULT[orderResult[2]].duplicate(true)
	result[orderResult[3]] = TEST_RESULT[orderResult[3]].duplicate(true)

# Called when the node enters the scene tree for the first time.
func _ready():
	var phrases: Array[String] = ["function avisarMaestro(pedido, arma) {", "	const ESPERA = \"ESPERA\"", "	const VEN = \"VEN\"", "	", "}"]
	ide.set_code(phrases)
	orderResult = gunsByTable.duplicate(true)
	randomize()
	orderResult.shuffle()
	test_result()
	DialogManager.connect('signalCloseDialog', close_dialog)
	player.connect("npcArrived",player_arrived)
	whipMaster.connect("npcArrived",player_arrived)
	ninjakuMaster.connect("npcArrived",player_arrived)
	saiMaster.connect("npcArrived",player_arrived)
	katanaMaster.connect("npcArrived",player_arrived)
	ide.connect("executeCodeSignal", sendCode)
	player.update_destination(playerSteps)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _clear_result():
	var key = orderResult[0]
	var values = result[key]
	lastAction = result[key][0]
	result[key].pop_front()
	if values.size() == 0:
		result.erase(key)
		orderResult.pop_front()
	elif lastAction == VEN:
		orderResult.pop_front()

func clear_arrive_master():
	var key = orderResult[0]
	orderResult.pop_front()
	result.erase(key)


func flow_process():
	var gun = ''
	if orderResult.size() > 0:
		gun = orderResult[0]
	if actualState == PLAYER_INIT:
		process_init(gun)
	elif actualState == PLAYER_MOVING:
		process_init(gun)
		pass
	elif actualState == MASTER_MOVING:
		init_state_player = MESSAGE_MASTER
		process_master_moving()
		pass
	elif actualState == PLAYER_CALL_MASTER:
		process_move_master(gun)
		pass
	elif actualState == PLAYER_WAIT_MASTER:
		process_wait_master()
		pass


func process_init(gun):
	if orderResult.size() == 0:
		process_move_player()
		return
	if init_state_player == MESSAGE_MASTER:
		init_state_player = MOVE_PLAYER
		var phrases: Array[String] = [gun]
		var msg_position = get_msg_gun_position()
		master.update_phrases(phrases, msg_position, true, {'auto_play_time': 0.7})
	elif init_state_player == MOVE_PLAYER:
		actualState = PLAYER_MOVING
		process_move_player()


func restart_all():
	error = true
	result = {
		'whip': ['ESPERA', 'ESPERA', 'ESPERA', 'VEN'],
		'sai': ['VEN', 'ESPERA', 'ESPERA', 'ESPERA'],
		'katana': ['ESPERA', 'VEN', 'ESPERA', 'ESPERA'],
		'ninjaku': ['ESPERA', 'ESPERA', 'VEN', 'ESPERA']
	}
	movedSaiMaster = false
	lastAction = ''
	init_state_player = MESSAGE_MASTER
	dialogPhases = false
	masterMoving = PLAYER_CALL_INIT
	actualDialogStates = INIT_DIALOG
	playerWaitting = false
	actualState = PLAYER_INIT
	playerState = PLAYER_ORIGIN
	firstCall = true
	var phrases: Array[String] = ["No es mi arma"]
	var msg_position = get_msg_gun_position()
	player.update_phrases(phrases, msg_position, true, {'auto_play_time': 0.7})


func process_move_master(gun):
	var valid = checkResult()
	if !valid:
		restart_all()
		return
	if masterMoving == PLAYER_CALL_INIT:
		masterMoving = PLAYER_SEND_MESSAGE
		var phrases: Array[String] = ["VEN"]
		var msg_position = get_msg_position()
		player.update_phrases(phrases, msg_position, true, {'auto_play_time': 0.7})
	elif masterMoving == PLAYER_SEND_MESSAGE:
		process_player_call_master(gun)


func process_wait_master():
	if masterMoving == PLAYER_CALL_INIT:
		masterMoving = PLAYER_SEND_MESSAGE
		var phrases: Array[String] = ["ESPERA"]
		var msg_position = get_msg_position()
		player.update_phrases(phrases, msg_position, true, {'auto_play_time': 0.7})
	elif masterMoving == PLAYER_SEND_MESSAGE:
		process_player_master_wait()


func get_msg_position():
	if playerState == IN_FIRST_TABLE:
		return Vector2(130,170)
	elif playerState == IN_SECOND_TABLE:
		return Vector2(188,170)
	elif playerState == IN_THIRD_TABLE:
		return Vector2(250,170)
	elif playerState == IN_FOURTY_TABLE:
		return Vector2(298,170)


func get_msg_gun_position():
	var gun = orderResult[0]
	if gun == 'sai':
		return Vector2(56,135)
	elif gun == 'katana':
		return Vector2(56,108)
	elif gun == 'ninjaku':
		return Vector2(56,83)
	elif gun == 'whip':
		return Vector2(56,55)


func checkResult():
	if playerState == IN_FIRST_TABLE:
		return gunsByTable[0] == orderResult[0]
	elif playerState == IN_SECOND_TABLE:
		return gunsByTable[1] == orderResult[0]
	elif playerState == IN_THIRD_TABLE:
		return gunsByTable[2] == orderResult[0]
	else:
		return gunsByTable[3] == orderResult[0]


func process_player_master_wait():
	masterMoving = PLAYER_CALL_INIT
	actualState = PLAYER_MOVING
	process_move_player()


func process_player_call_master(gun: String):
	masterMoving = PLAYER_CALL_INIT
	actualState = MASTER_MOVING
	if (gun == 'sai'):
		movedSaiMaster = true
	move_master(gun)


func process_master_moving():
	actualState = PLAYER_MOVING
	clear_arrive_master()
	move_initial_position()


func process_player_moving():
	process_move_player()


func process_move_player():
	if playerState == PLAYER_ORIGIN:
		process_player_from_origin()
	elif playerState == IN_FIRST_TABLE:
		process_player_from_table(secondTablePosition, IN_SECOND_TABLE)
	elif playerState == IN_SECOND_TABLE:
		process_player_from_table(thirdTablePosition, IN_THIRD_TABLE)
	elif playerState == IN_THIRD_TABLE:
		process_player_from_table(fourthTablePosition, IN_FOURTY_TABLE)
	elif playerState == IN_FOURTY_TABLE:
		process_player_from_table(finalPosition, PLAYER_ORIGIN)

func process_player_from_origin():
	if orderResult.size() == 0:
		print("FIN")
	else:
		playerState = IN_FIRST_TABLE
		player.update_destination(firstTablePosition)

func process_player_from_table(positions: Array[Vector2], nexState):
	var gun = orderResult[0]
	var actualAction = get_next_action()
	if actualAction == VEN:
		actualState = PLAYER_CALL_MASTER
		lastAction = VEN
		flow_process()
	elif playerWaitting:
		_clear_result()
		playerWaitting = false
		playerState = nexState
		actualState = PLAYER_MOVING
		player.update_destination(positions)
	else:
		playerWaitting = true
		actualState = PLAYER_WAIT_MASTER
		flow_process()


func get_next_action():
	var key = orderResult[0]
	var values = result[key]
	var step = values[0]
	return step

func show_master_message(key: String, step):
	var master = get_master(key)
	var messageData = get_master_message(key, step)
	master.update_phrases(messageData['message'], messageData['position'], true)


func move_initial_position():
	playerState = PLAYER_ORIGIN
	player.update_destination(finalPosition)


func player_arrived():
	if error:
		error = false
		return
	if !firstCall:
		flow_process()
	else:
		flow_dialog()
	firstCall = false


func move_master(gun: String):
	if gun == 'katana':
		if movedSaiMaster:
			katanaMaster.update_destination(alternativeKatanaMasterSteps)
		else:
			katanaMaster.update_destination(katanaMasterSteps)
	elif gun == 'sai':
		saiMaster.update_destination(saiMasterSteps)
	elif gun == 'ninjaku':
		ninjakuMaster.update_destination(ninjakuMasterSteps)
	else:
		whipMaster.update_destination(whipMasterSteps)


func get_master(gun: String):
	if gun == 'katana':
		return katanaMaster
	elif gun == 'sai':
		return saiMaster
	elif gun == 'ninjaku':
		return ninjakuMaster
	else:
		return whipMaster


func get_master_message(gun: String, step: String):
	if gun == 'katana':
		return get_katanaMaster_message(step)
	elif gun == 'sai':
		return get_saiMaster_message(step)
	elif gun == 'ninjaku':
		return get_ninjakuMaster_message(step)
	else:
		return get_whipMaster_message(step)


func get_katanaMaster_message(step):
	if step == INITIAL:
		return {
			'message': ['Busca la Katana'],
			'position': Vector2(35,78)
		}
	elif step == FINAL_OK:
		return {
			'message': ['Muy bien!'],
			'position': Vector2(288,128)
		}
	else:
		return {
			'message': ['Lo siento, esa no es la Kantana'],
			'position': Vector2(35,78)
		}


func get_whipMaster_message(step):
	if step == INITIAL:
		return {
			'message': ['Busca el Whip'],
			'position': Vector2(35,78)
		}
	elif step == FINAL_OK:
		return {
			'message': ['Muy bien!'],
			'position': Vector2(288,128)
		}
	else:
		return {
			'message': ['Lo siento, esa no es el Whip'],
			'position': Vector2(35,78)
		}


func get_ninjakuMaster_message(step):
	if step == INITIAL:
		return {
			'message': ['Busca el Ninjaku'],
			'position': Vector2(35,103)
		}
	elif step == FINAL_OK:
		return {
			'message': ['Muy bien!'],
			'position': Vector2(240,128)
		}
	else:
		return {
			'message': ['Lo siento, esa no es el Ninjaku'],
			'position': Vector2(35,103)
		}


func get_saiMaster_message(step):
	if step == INITIAL:
		return {
			'message': ['Busca el Sai'],
			'position': Vector2(35,155)
		}
	elif step == FINAL_OK:
		return {
			'message': ['Muy bien!'],
			'position': Vector2(178,128)
		}
	else:
		return {
			'message': ['Lo siento, ese no es el Sai'],
			'position': Vector2(35,155)
		}


func sendCode(code):
	flow_process()


func flow_dialog():
	if actualDialogStates == INIT_DIALOG:
		talk_master()
		actualDialogStates = FIRST_DIALOG_MASTER
	elif actualDialogStates == FIRST_DIALOG_MASTER:
		var phrases: Array[String] = ["Sai"]
		master.update_phrases(phrases, Vector2(56,135), true, {'auto_play_time': 0.7, 'close_by_signal': true})
		actualDialogStates = FIRST_GUN_MASTER
		pass
	elif actualDialogStates == FIRST_GUN_MASTER:
		var phrases: Array[String] = ["Katana"]
		master.update_phrases(phrases, Vector2(56,108), true, {'auto_play_time': 0.7, 'close_by_signal': true})
		actualDialogStates = SECOND_GUN_MASTER
		pass
	elif actualDialogStates == SECOND_GUN_MASTER:
		var phrases: Array[String] = ["Ninjaku"]
		master.update_phrases(phrases, Vector2(56,83), true, {'auto_play_time': 0.7, 'close_by_signal': true})
		actualDialogStates = THIRD_GUN_MASTER
		pass
	elif actualDialogStates == THIRD_GUN_MASTER:
		var phrases: Array[String] = ["Whip"]
		master.update_phrases(phrases, Vector2(56,55), true, {'auto_play_time': 0.7, 'close_by_signal': true})
		actualDialogStates = FOURTH_GUN_MASTER
		pass
	elif actualDialogStates == FOURTH_GUN_MASTER:
		actualDialogStates = SECOND_DIALOG_MASTER
		talk_master()
	else:
		dialogPhases = false

func talk_master():
	var phrases: Array[String] = []
	if actualDialogStates == INIT_DIALOG:
		phrases = [
			"Bienvenido, es hora de aprender las principales armas", 
			"Para eso los maestros te enseñaran a utilizarlas",
			"Pero antes debes reconocer cada arma",
			"Cada maestro te dira su arma"
		]
	elif actualDialogStates == SECOND_DIALOG_MASTER:
		phrases = [
			"Escribe una función que recibe como parametro el arma pedida por el maestro y el arma de la mesa",
			"Si coinciden retornar 'VEN'",
			"Si no coincide retornar 'ESPERA'"
		]
	
	master.update_phrases(phrases, Vector2(56,155), true, {'auto_play_time': 1, 'close_by_signal': true})



func close_dialog():
	if error:
		player.update_destination(finalPosition)
		return
	if dialogPhases:
		flow_dialog()
	else:
		flow_process()
