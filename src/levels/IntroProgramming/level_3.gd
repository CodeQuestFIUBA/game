extends Node2D


@onready var player = $player
@onready var master = $master
@onready var IDE = $CanvasLayer/IDE
@onready var first_guardian = $first_guradian
@onready var second_guardian = $second_guradian
var nextLevel = "res://levels/IntroProgramming/level_4.tscn"

var final_setps: Array[Vector2] = [ Vector2(216,-16)]

var player_first_left: Array[Vector2] = [ Vector2(184, 176), Vector2(72,176), Vector2(72,128), Vector2(56,128), Vector2(56,112), Vector2(184,112)]
var player_first_right: Array[Vector2] = [ Vector2(184, 176), Vector2(312,176), Vector2(312,144), Vector2(328,144), Vector2(328,112), Vector2(184,112)]
var player_second_left: Array[Vector2] = [ Vector2(56, 112), Vector2(56, 56), Vector2(72, 56), Vector2(72, 32), Vector2(216, 32)]
var player_second_right: Array[Vector2] = [ Vector2(328, 112), Vector2(328, 48), Vector2(328, 48), Vector2(296, 48), Vector2(296, 32), Vector2(216, 32)]


var first_guardian_left: Array[Vector2] = [ Vector2(56, 104), Vector2(56, 136)]
var first_guardian_right: Array[Vector2] = [ Vector2(328, 104), Vector2(328, 152)]

var second_guardian_left: Array[Vector2] = [ Vector2(72, 40), Vector2(72, 56), Vector2(72, 56), Vector2(56, 56), Vector2(56, 72)]
var second_guardian_right: Array[Vector2] = [ Vector2(296, 40), Vector2(296, 48), Vector2(328, 48), Vector2(328, 72)]


var master_msg_position = Vector2(104,126)

var executing_code = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if ApiService:
		ApiService.connect("signalApiResponse", process_response)
	IDE.connect("executeCodeSignal", sendCode)
	var phrases: Array[String] = [
		"Shhh Bitama, estamos cerca de encontrar a JR…",
		"Sus guardias están vigilando la zona…",
		"Pero no estamos listos para luchar contra ellos, deberemos utilizar el sigilo ninja para esquivarlos…",
		"Pero por orden de JR, ellos se mueven con un patrón determinado según la hora del día…",
		"Y un ninja aliado estaba observándolos y nos dio dos mensajes con sus movimientos…",
		"Utilízalos para atravesar el camino con sigilo y no ser detectado…"
	]
	await show_master_messages(phrases)
	var codeLines: Array[String] = ["let mensaje1 = getPosicionPrimerGuardia();","let mensaje2 = getPosicionSegundoGuardia();"]
	IDE.set_code(codeLines)
	loadHelp()

func _process(delta):
	pass


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


func show_master_messages(phrases: Array[String]):
	master.update_phrases(phrases, master_msg_position, true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog


func test_result():
	pass


func loadHelp():
	var phrases: Array[String] = [
		"Recuerda comparar los mensajes con el valor \"IZQUIERDA\" o \"DERECHA\"...",
		"Recuerda tomar el camino opuesto al del guardia...",
		"Recuerda indicarle a Bitama que camino debe tomar..."
	]
	master.update_phrases(phrases, master_msg_position, false, {'auto_play_time': 1, 'close_by_signal': true})



func show_error_response(error: String):
	var phrases: Array[String] = [
		"Lo siento Bitama, pero no logre ejecutar tu código",
		"Me retorno el siguiente mensaje",
		error,
		"¡Corrigelo y vuelve a intentarlo!"
	]
	show_message(phrases)


func process_result(result):
	if len(result["posiciones"]) < 2:
		show_empty_road_msg();
		return
	if result["posiciones"][0] == result["posicionesGuardias"][0]:
		show_wrong_first_road_msg()
		return
	if result["posiciones"][1] == result["posicionesGuardias"][1]:
		show_wrong_second_road_msg()
		return
	var phrases: Array[String] = [
		"¡¡Vamos Bitama, confío en ti, esquiva a esos guardias!!"
	]
	await show_message(phrases)
	if result["posiciones"][0] == "IZQUIERDA":
		player.update_destination(player_first_left)
		first_guardian.update_destination(first_guardian_right)
	else:
		player.update_destination(player_first_right)
		first_guardian.update_destination(first_guardian_left)
	await player.npcArrived
	phrases = [
		"¡¡Muy bien Bitama, lograste esquivar al primer guardia, sigue así!!"
	]
	await show_message(phrases)
	if result["posiciones"][1] == "IZQUIERDA":
		player.update_destination(player_second_left)
		second_guardian.update_destination(second_guardian_right)
	else:
		player.update_destination(player_second_right)
		second_guardian.update_destination(second_guardian_left)
	await player.npcArrived
	phrases = [
		"¡¡Muy bien Bitama, lograste esquivar a los dos guardias!!",
		"Es hora de seguir el camino para derrotar a JR..."
	]
	await show_message(phrases)
	player.update_destination(final_setps)
	complete_level()
	await player.npcArrived
	next()

func show_empty_road_msg():
	var phrases: Array[String] = [
		"Mmmm, recuerda que tienes que seleccionar un camino...",
		"¡¡Vamos Bitama!!"
	]
	show_message(phrases)
	add_attempt()


func show_wrong_first_road_msg():
	var phrases: Array[String] = [
		"Mmmm, no es que no confie en vos pero dejame revisar el camino que tomarás...",
		"...",
		"...",
		"Te encontrarás con el primer guardia si sigues este camino...",
		"Vuelve a intentarlo..."
	]
	show_message(phrases)
	add_attempt()


func show_wrong_second_road_msg():
	var phrases: Array[String] = [
		"Mmmm, no es que no confie en vos pero dejame revisar el camino que tomarás...",
		"...",
		"...",
		"Te encontrarás con el segundo guardia si sigues este camino...",
		"Vuelve a intentarlo..."
	]
	show_message(phrases)
	add_attempt()


func show_message(phrases):
	master.update_phrases(phrases, master_msg_position, true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	executing_code = false
	loadHelp()


func sendCode(code):
	if executing_code:
		return
	executing_code = true
	var body = 	"function intro() {\n" + code + "\n}"
	ApiService.send_request(body, HTTPClient.METHOD_POST, "intro/ifElse", "SEND_CODE")

func add_attempt():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, "score/attempts/bases_de_la_programacion/2", "ADD_ATTEMPT")
	
func complete_level():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, "score/complete/bases_de_la_programacion/2", "COMPLETE_LEVEL")

func next():
	LevelManager.load_scene(get_tree().current_scene.scene_file_path, nextLevel)
