extends Node2D

@onready var player = $Player
@onready var master = $Master
@onready var IDE = $CanvasLayer/IDE
var nextLevel = "res://levels/IntroProgramming/level_3.tscn"


var road_1_steps: Array[Vector2] = [ Vector2(200,120), Vector2(-16,120)]
var road_2_setps: Array[Vector2] = [ Vector2(200,120), Vector2(264,120), Vector2(264, -16)]
var road_3_setps: Array[Vector2] = [ Vector2(200,120), Vector2(264,120), Vector2(264, 136), Vector2(408, 136)]

var master_msg_position: Vector2 = Vector2(72, 170)

var executing_code = false


# Called when the node enters the scene tree for the first time.
func _ready():
	if ApiService:
		ApiService.connect("signalApiResponse", process_response)
	#ApiService.login("mafvidal35@gmail.com", "Asd123456+", "LOGIN");
	IDE.connect("executeCodeSignal", sendCode)
	var phrases: Array[String] = [
		"Hola Bitama…",
		"Nuevamente otra ciudad que fue abandonada por los desastres causados por JR…",
		"Debemos seguir el camino de destrucción de JR, para vencerlo y acabar con su daños casi irreparables…",
		"Encuentra un mapa y sigue el camino indicado…"
	]
	await show_master_messages(phrases)
	set_code()
	loadHelp()

func loadHelp():
	var phrases: Array[String] = [
		"Recueda utilizar la función recogerMapa() que te retornara el valor del camino a seguir",
		"Recueda utilizar la función elegirCamino(camino) que nos llevara al camino correcto"
	]
	master.update_phrases(phrases, master_msg_position, false, {'auto_play_time': 1, 'close_by_signal': true})

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

func set_code():
	var codeLines: Array[String] = [
		"// recogerMapa()",
		"// buscarCamino()",
		"// elegirCamino(camino)"
	]
	IDE.set_code(codeLines)


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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func show_master_messages(phrases: Array[String]):
	master.update_phrases(phrases, master_msg_position, true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog


func process_result(result):
	var phrases: Array[String] = [
		"Segun el mapa, debemos seguir el camino " + str(result["caminoElegido"])
	]
	player.update_phrases(phrases, Vector2(150, 184), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	if !result["completado"]:
		show_error_messages(result)
		return
	phrases = [
		"Bien hecho Bitama ¡¡encontraste el camino correcto!!",
		"Ahora sigamos en la busqueda de JR..."
	]
	complete_level()
	await show_master_messages(phrases)
	if result["caminoCorrecto"] == 1:
		player.update_destination(road_1_steps)
	elif result["caminoCorrecto"] == 2:
		player.update_destination(road_2_setps)
	else:
		player.update_destination(road_3_setps)
	await player.npcArrived
	next()


func show_error_messages(result):
	var phrases: Array[String] = []
	if result["caminoCorrecto"] != result["caminoElegido"]:
		phrases = [
			"Lo siento Bitama, el camino elegido es incorrecto. Vuelve a intentarlo..."
		]
	elif !result["tomoMapaCorrectamente"]:
		phrases = [
			"Lo siento Bitama, debes seguir los pasos en el orden correspondiente para encontrar el camino correcto..."
		]
	await show_master_messages(phrases)
	add_attempt()
	executing_code = false
	set_code()
	loadHelp()

func sendCode(code = null):
	if executing_code:
		return
	executing_code = true
	var body = 	"function intro() {\n" + code + "\n}"
	ApiService.send_request(body, HTTPClient.METHOD_POST, "intro/functions", "SEND_CODE")

func add_attempt():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, "score/attempts/bases_de_la_programacion/1", "ADD_ATTEMPT")
	
func complete_level():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, "score/complete/bases_de_la_programacion/1", "COMPLETE_LEVEL")


func next():
	get_tree().change_scene_to_file(nextLevel)
