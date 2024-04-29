extends Node2D

@onready var whipMaster = $WhipMaster
@onready var ninjakuMaster = $NinjakuMaster
@onready var katanaMaster = $katanaMaster
@onready var saiMaster = $SaiMaster
@onready var master = $Master
@onready var player = $Player
@onready var IDE = $CanvasLayer/IDE

var playerSteps: Array[Vector2] = [ Vector2(86,180), Vector2(208,180) ]
var playerFinish: Array[Vector2] = [ Vector2(86,180), Vector2(86,216) ]
var whipMasterSteps: Array[Vector2] = [ Vector2(288,78), Vector2(288,128) ]
var returnWhipMaster: Array[Vector2] = [ Vector2(288,78), Vector2(35,78) ]
var ninjakuMasterSteps: Array[Vector2] = [ Vector2(240,103), Vector2(240,128) ]
var returnNinjakuMaster: Array[Vector2] = [ Vector2(240,103), Vector2(35,103) ]
var saiMasterSteps: Array[Vector2] = [ Vector2(70,128), Vector2(120,128) ]
var returnSaiMaster: Array[Vector2] = [ Vector2(70,128), Vector2(35,155) ]
var katanaMasterSteps: Array[Vector2] = [ Vector2(178,128) ]
var returnKatanMaster: Array[Vector2] = [ Vector2(35,128) ]
var alternativeKatanaMasterSteps: Array[Vector2] = [ Vector2(70,128), Vector2(70,103), Vector2(178,103), Vector2(178,128)]
var firstTablePosition: Array[Vector2] = [Vector2(120,170)]
var secondTablePosition: Array[Vector2] = [Vector2(178,170)]
var thirdTablePosition: Array[Vector2] = [Vector2(240,170)]
var fourthTablePosition: Array[Vector2] = [Vector2(288,170)]
var finalPosition: Array[Vector2] = [Vector2(208,180)]
const VEN: String = 'VEN'
const ESPERA: String = 'ESPERA'
var movedSaiMaster = false

var result = {}
const TEST_RESULT = {
	'sai': ['VEN', 'ESPERA', 'ESPERA', 'ESPERA'],
	'katana': ['ESPERA', 'VEN', 'ESPERA', 'ESPERA'],
	'ninjaku': ['ESPERA', 'ESPERA', 'VEN', 'ESPERA'],
	'whip': ['ESPERA', 'ESPERA', 'ESPERA', 'VEN']
}
var orderResult: Array[String] = []
var gunsByTable: Array[String] = ['sai', 'katana', 'ninjaku', 'whip']
var move_masters = {
	'whip': false,
	'sai': false,
	'katana': false,
	'ninjaku': false
}

var executing_code = false

func test_result():
	result[orderResult[0]] = TEST_RESULT[orderResult[0]].duplicate(true)
	result[orderResult[1]] = TEST_RESULT[orderResult[1]].duplicate(true)
	result[orderResult[2]] = TEST_RESULT[orderResult[2]].duplicate(true)
	result[orderResult[3]] = TEST_RESULT[orderResult[3]].duplicate(true)


func _ready():
	orderResult = gunsByTable.duplicate(true)
	randomize()
	orderResult.shuffle()
	ApiService.connect("signalApiResponse", process_response)
	IDE.connect("executeCodeSignal", sendCode)
	ModalManager.on_modal_primary_pressed.connect(closeModal) 
	ModalManager.on_modal_secondary_pressed.connect(closeModal) 
	await process_intro()


func process_intro():
	player.update_destination(playerSteps)
	await player.npcArrived
	var phrases: Array[String] = []
	phrases = [
		"Bienvenido, es hora de aprender las principales armas de un ninja", 
		"Para eso los maestros te enseñaran a utilizarlas",
		"Pero antes debes ser capaz de reconocerlas",
		"Cada maestro te dira su arma"
	]
	master.update_phrases(phrases, Vector2(56,155), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	phrases = ["Sai"]
	master.update_phrases(phrases, Vector2(56,135), true, {'auto_play_time': 0.7, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	phrases = ["Katana"]
	master.update_phrases(phrases, Vector2(56,108), true, {'auto_play_time': 0.7, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	phrases = ["Ninjaku"]
	master.update_phrases(phrases, Vector2(56,83), true, {'auto_play_time': 0.7, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	phrases = ["Whip"]
	master.update_phrases(phrases, Vector2(56,55), true, {'auto_play_time': 0.7, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	phrases = [
		"Escribe una función que recibe como parametro el arma pedida por el maestro y el arma de la mesa",
		"Si coinciden retornar 'VEN'",
		"Si no coincide retornar 'ESPERA'",
		"Si necesitas ayuda, te podre dar consejos si haces click sobre mi"
	]
	master.update_phrases(phrases, Vector2(56,155), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	var codeLines: Array[String] = ["function avisarMaestro(pedido, arma) {", "	const ESPERA = \"ESPERA\"", "	const VEN = \"VEN\"", "	", "}"]
	IDE.set_code(codeLines)
	phrases = [
		"Presiona la tecla M para ver la consigna",
		"Puedes utilizar un if para evaluar si las armas son iguales",
		"Intenta retornar las constantes 'ESPERA' y 'VEN'"
	]
	master.update_phrases(phrases, Vector2(56,155), false, {'auto_play_time': 1, 'close_by_signal': true})


func openModal():
	ModalManager.open_modal({
		'title': "Instrucciones",
		'description': "Escribe una función que recibe como parametro el arma pedida por el maestro y el arma de la mesa. Si coinciden retornar 'VEN'. Si no coincide retornar 'ESPERA'",
		'title_font_size': 8,
		'description_font_size': 6,
		'primary_button_label': "Aceptar",
		'secondary_button_label': "Cancelar"
	})


func closeModal():
	ModalManager.close_modal()


func process_result(valid: bool):
	if !valid:
		print("invalid")
		return
	for i in range(orderResult.size()):
		var gun = orderResult[i]
		await master_say_gun(gun)
		var response = result[gun]
		for j in range(response.size()):
			var msg = response[j]
			var result = await process_move_player(j, gun, response[j])
			if !result:
				return
			if msg == VEN:
				break
	var phrases: Array[String] = [
		"Felicitaciones!!! Lograste completar el nivel", 
		"Ahora estas listo para el siguiente desafio"
	]
	master.update_phrases(phrases, Vector2(56,155), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	player.update_destination(playerFinish)
	await player.npcArrived

func master_say_gun(gun: String):
	var phrases: Array[String] = []
	var msg_position = get_msg_gun_position(gun)
	match gun:
		'sai':
			phrases = ['Sai']
		'katana':
			phrases = ['Katana']
		'ninjaku':
			phrases = ['Ninjaku']
		'whip':
			phrases = ['Whip']
	master.update_phrases(phrases, msg_position, true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog


func process_move_player(table: int, gun: String, msg: String) -> bool:
	await move_player_to_table(table)
	await player_say_msg(table, msg)
	if msg == ESPERA:
		return true
	if msg == VEN && gun != gunsByTable[table]:
		await process_error_result(gun)
		return false
	else:
		await move_master(gun)
		player.update_destination(finalPosition)
		await player.npcArrived
		return true


func process_error_result(gun: String):
	var phrases: Array[String] = []
	phrases = ["No es mi arma"]
	var msg_position = get_msg_gun_position(gun)
	master.update_phrases(phrases, msg_position, true, {'auto_play_time': 0.7})
	await DialogManager.signalCloseDialog
	phrases = ["Vamos a intentarlo nuevamente"]
	master.update_phrases(phrases, Vector2(56,155), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	await return_all()
	player.update_destination(finalPosition)
	await player.npcArrived
	restart_all()


func move_player_to_table(table: int):
	match table:
		0:
			player.update_destination(firstTablePosition)
		1:
			player.update_destination(secondTablePosition)
		2:
			player.update_destination(thirdTablePosition)
		3:
			player.update_destination(fourthTablePosition)
	await player.npcArrived


func player_say_msg(table: int, msg: String):
	var msg_position: Vector2
	var phrases: Array[String] = []
	if msg == VEN:
		phrases = ['Ven']
	else:
		phrases = ['Espera']
	match table:
		0:
			msg_position = Vector2(130,170)
		1:
			msg_position = Vector2(188,170)
		2:
			msg_position = Vector2(250,170)
		3:
			msg_position = Vector2(298,170)
	player.update_phrases(phrases, msg_position, true, {'auto_play_time': 0.7})
	await DialogManager.signalCloseDialog


func move_master(gun: String):
	move_masters[gun] = true
	if gun == 'katana':
		if movedSaiMaster:
			katanaMaster.update_destination(alternativeKatanaMasterSteps)
		else:
			katanaMaster.update_destination(katanaMasterSteps)
		await katanaMaster.npcArrived
	elif gun == 'sai':
		saiMaster.update_destination(saiMasterSteps)
		movedSaiMaster = true
		await saiMaster.npcArrived
	elif gun == 'ninjaku':
		ninjakuMaster.update_destination(ninjakuMasterSteps)
		await ninjakuMaster.npcArrived
	else:
		whipMaster.update_destination(whipMasterSteps)
		await whipMaster.npcArrived


func talk_intro_master():
	var phrases: Array[String] = [
		"Bienvenido, es hora de aprender las principales armas de un ninja", 
		"Para eso los maestros te enseñaran a utilizarlas",
		"Pero antes debes ser capaz de reconocerlas",
		"Cada maestro te dira su arma"
	]
	master.update_phrases(phrases, Vector2(56,155), true, {'auto_play_time': 1, 'close_by_signal': true})


func _process(delta):
	pass

func _unhandled_input(event):
	if event.is_action_pressed("show_modal"):
		openModal()


func restart_all():
	movedSaiMaster = false
	executing_code = false
	orderResult = gunsByTable.duplicate(true)
	randomize()
	orderResult.shuffle()
	test_result()


func return_all():
	var signals
	if move_masters['sai']:
		move_masters['sai'] = false
		saiMaster.update_destination(returnSaiMaster)
		signals = saiMaster.npcArrived
	if move_masters['katana']:
		move_masters['katana'] = false
		katanaMaster.update_destination(returnKatanMaster)
		signals = signals and katanaMaster.npcArrived
	if move_masters['ninjaku']:
		move_masters['ninjaku'] = false
		ninjakuMaster.update_destination(returnNinjakuMaster)
		signals = signals and ninjakuMaster.npcArrived
	if move_masters['whip']:
		move_masters['whip'] = false
		whipMaster.update_destination(returnWhipMaster)
		signals = signals and whipMaster.npcArrived
	await signals
	player.update_destination(finalPosition)


func get_msg_gun_position(gun: String):
	if gun == 'sai':
		return Vector2(56,135)
	elif gun == 'katana':
		return Vector2(56,108)
	elif gun == 'ninjaku':
		return Vector2(56,83)
	elif gun == 'whip':
		return Vector2(56,55)


func get_master(gun: String):
	if gun == 'katana':
		return katanaMaster
	elif gun == 'sai':
		return saiMaster
	elif gun == 'ninjaku':
		return ninjakuMaster
	else:
		return whipMaster


func sendCode(code):
	if executing_code:
		return
	var orderCalls = "["
	for value in orderResult:
		orderCalls += "'" + value + "', "
		print(value)
	orderCalls += "]"
	var globalVariables = "
	function process(result) {
	var guns = ['sai', 'katana', 'ninjaku', 'whip'];
	var orderCalls = " + orderCalls
	var initialSegmentCode = "
		for (let i = 0; i <= orderCalls.length - 1 ; i++) {
			var msgs = [];
			for (let j = 0; j <= guns.length - 1 ; j++) {
				var msg = avisarMaestro(orderCalls[i], guns[j])
				msgs.push(msg.trim().toUpperCase())
			}
			result[orderCalls[i]] = msgs;
		}

		return result
	}
	"
	var finalSegmentCode = "
	let result = {}
	process(result);
	"
	var finalCode = globalVariables + "\n" + initialSegmentCode + "\n" + code  + "\n" + finalSegmentCode
	executing_code = true
	#TODO: REMOVE
	test_result()
	process_result(true)


func process_response(resp):
	#TODO: ADD resp to result
	process_result(true)

