extends Node2D


@onready var player = $Player
@onready var master = $Master
@onready var IDE = $CanvasLayer/IDE
var executing_code = false
var nextLevel = "res://levels/seach/level_3.tscn"

var master_msg_position: Vector2 = Vector2(96, 176)
var box_with_scroll = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	ApiService.connect("signalApiResponse", process_response)
	IDE.connect("executeCodeSignal", sendCode)
	var phrases: Array[String] = [
		"Hola Bitama...",
		"Para vencer a Kuzumi, debemos tomar la poción de mayor potencia...",
		"Nuestros enemigos estuvieron mezclandolas...",
		"Por lo que deberas revisar la etiqueta de cada una y seleccionar la de mayor potencia..."
	]
	await show_message(phrases)
	set_code()
	loadHelp()


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
	show_message(phrases)


func show_message(phrases):
	master.update_phrases(phrases, master_msg_position, true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	executing_code = false
	loadHelp()


func loadHelp():
	var phrases: Array[String] = [
		"Recuerda retornar el índice y no el valor máximo...",
		"Recuerda que el índice inicia en cero..."
	]
	master.update_phrases(phrases, master_msg_position, false, {'auto_play_time': 1, 'close_by_signal': true})



func set_code():
	var codeLines: Array[String] = [
		"function funcion(pociones) {",
		"	",
		"}"
	]
	IDE.set_code(codeLines)


func get_posion_steps(index: int) -> Array[Vector2]:
	match index:
		0: return [
				Vector2(40, 128)
			]
		1: return [
				Vector2(104, 128),
				Vector2(104, 96)
			]
		2: return [
				Vector2(168, 96),
				Vector2(168, 64)
			]
		3: return [
				Vector2(232, 64)
			]
		4: return [
				Vector2(232, 96),
				Vector2(296, 96)
			]
		_: return [
				Vector2(296, 128),
				Vector2(360, 128)
			]


func get_Final_pos(index: int) -> Array[Vector2]:
	match index:
		0: return [
				Vector2(40, 128)
			]
		1: return [
				Vector2(104, 96)
			]
		2: return [
				Vector2(168, 64)
			]
		3: return [
				Vector2(232, 64)
			]
		4: return [
				Vector2(296, 96)
			]
		_: return [
				Vector2(360, 128)
			]


func process_result(result):
	var masterPhrases: Array[String] = []
	var playerPhrases: Array[String] = []
	var potions = result["pociones"]
	var index = result["index"]
	var maxIndex = result["maxIndex"]
	var maxPotion = potions[maxIndex]
	for i in range(potions.size()):
		var steps: Array[Vector2] = get_posion_steps(i);
		player.update_destination(steps)
		await player.npcArrived
		var bottle = potions[i]
		masterPhrases = ["La potencia es " + str(bottle)]
		await show_message(masterPhrases)
	var steps: Array[Vector2] = [Vector2(200, 168)]
	player.update_destination(steps)
	await player.npcArrived
	if index == maxIndex:
		finish_game(index, str(maxPotion))
	else:
		restart(str(maxIndex), str(maxPotion), str(index))

func restart(max_index, potion, index):
	add_attempt()
	var playerPhrases: Array[String] = ["La maxima potencia la encontre en la posición " + index]
	await show_message(playerPhrases)
	var masterPhrases: Array[String] = [
		"Lo siento Bitama, la poción más potente es la que esta en " + max_index + " y con el valor de " + potion,
		"Volvamos a intentarlo"
	]
	await show_message(masterPhrases)
	executing_code = false
	loadHelp()
	

func finish_game(index, maxPotion):
	complete_level()
	var playerPhrases: Array[String] = ["La maxima potencia que encontre es " + maxPotion]
	await show_message(playerPhrases)
	var masterPhrases: Array[String] = ["Muy bien, vamos a utilizarla para obtener mayor fuerza y vencer a Kuzumi"]
	await show_message(masterPhrases)
	var final_pos = get_Final_pos(index);
	player.update_destination(final_pos)
	await player.npcArrived
	masterPhrases = ["Muy bien, estamos listos para vencer a Kuzumi"]
	await show_message(masterPhrases)
	var steps: Array[Vector2] = [
		Vector2(200, 144),
		Vector2(200, 240)
	]
	player.update_destination(steps)
	await player.npcArrived
	next()


func sendCode(code):
	if executing_code:
		return
	executing_code = true
	ApiService.send_request(code, HTTPClient.METHOD_POST, "vectors/max", "SEND_CODE")

func add_attempt():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, "score/attempts/vectores/1", "ADD_ATTEMPT")
	
func complete_level():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, "score/complete/vectores/1", "COMPLETE_LEVEL")


func next():
	LevelManager.load_scene(get_tree().current_scene.scene_file_path, nextLevel)
