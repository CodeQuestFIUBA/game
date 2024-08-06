extends Node2D

@onready var whipMaster = $WhipMaster
@onready var ninjakuMaster = $NinjakuMaster
@onready var katanaMaster = $katanaMaster
@onready var saiMaster = $SaiMaster
@onready var master = $Master
@onready var player = $Player
@onready var IDE = $CanvasLayer/IDE
var nextLevel = "res://levels/Function/level_2.tscn"

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
var master_msg_position: Vector2 = Vector2(56,155)
const VEN: String = 'VEN'
const ESPERA: String = 'ESPERA'
var movedSaiMaster = false

var result = {}

var orderResult: Array[String] = []
var gunsByTable: Array[String] = ['sai', 'katana', 'ninjaku', 'whip']
var move_masters = {
	'whip': false,
	'sai': false,
	'katana': false,
	'ninjaku': false
}

var executing_code = false


func _ready():
	ApiService.connect("signalApiResponse", process_response)
	IDE.connect("executeCodeSignal", sendCode)
	await process_intro()


func process_response(res, extraArg):
	match extraArg:
		"LOGIN": pass
		"COMPLETE_LEVEL": pass
		"ADD_ATTEMPT": pass
		"SEND_CODE": 
			if !res || res["code"] != 200:
				show_error_response(res["message"])
				return;
			process_result(res["data"]["result"])


func show_error_response(error: String):
	var phrases: Array[String] = [
		"Lo siento Bitama, pero no logre ejecutar tu código",
		"Me retorno el siguiente mensaje",
		error,
		"¡Corrigelo y vuelve a intentarlo!"
	]
	master.update_phrases(phrases, master_msg_position, true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	executing_code = false
	loadHelp()


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
	loadHelp()
	set_code()
	
func set_code():
	var codeLines: Array[String] = ["function avisarMaestro(pedido, arma) {", "	const ESPERA = \"ESPERA\"", "	const VEN = \"VEN\"", "	", "}"]
	IDE.set_code(codeLines)

func loadHelp():
	var phrases: Array[String] = [
		"Puedes utilizar un if para evaluar si las armas son iguales",
		"Intenta retornar las constantes 'ESPERA' y 'VEN'"
	]
	master.update_phrases(phrases, master_msg_position, false, {'auto_play_time': 1, 'close_by_signal': true})

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


func process_result(data):
	var result = data["pedido"]
	var orderResult = data["armas"]
	for i in range(orderResult.size()):
		var gun = orderResult[i]
		await master_say_gun(gun)
		var response = result[gun]
		for j in range(response.size()):
			var msg = response[j]
			var resultRequest = await process_move_player(j, gun, response[j])
			if !resultRequest:
				return
			if msg == VEN:
				break
	var phrases: Array[String] = [
		"Felicitaciones!!! Lograste completar el nivel", 
		"Ahora estas listo para el siguiente desafio"
	]
	complete_level()
	master.update_phrases(phrases, master_msg_position, true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	player.update_destination(playerFinish)
	await player.npcArrived
	next()

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
	add_attempt()
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
	executing_code = true
	ApiService.send_request(code, HTTPClient.METHOD_POST, "functions/intro", "SEND_CODE")
	

func add_attempt():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, "score/attempts/funciones_y_operadores/0", "ADD_ATTEMPT")
	
func complete_level():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, "score/complete/funciones_y_operadores/0", "COMPLETE_LEVEL")
	
	
func next():
	LevelManager.load_scene(get_tree().current_scene.scene_file_path, nextLevel)
	

