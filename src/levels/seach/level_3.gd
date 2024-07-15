extends Node2D


@onready var player = $Player
@onready var master = $Master
@onready var enemy = $Enemy
@onready var IDE = $CanvasLayer/IDE
@onready var first_indicator = $FirstIndicator_1
@onready var second_indicator = $SecondIndicator_1
@onready var scroll = $TileMap2
@onready var label: RichTextLabel = $RichTextLabel
@onready var label_enemy = $RichTextLabel2
var executing_code = false

var master_msg_position: Vector2 = Vector2(80, 152)
var box_with_scroll = 4

var player_first_steps: Array[Vector2] = [
	Vector2(136, 104),
	Vector2(56,104)
]

var player_attack_steps: Array[Vector2] = [
	Vector2(328, 104)
]

var player_final_steps: Array[Vector2] = [
	Vector2(304, 104),
	Vector2(304, 144),
	Vector2(416, 144)
]

var enemy_first_steps: Array[Vector2] = [
	Vector2(272, 104),
	Vector2(344, 104)
]

var master_first_steps: Array[Vector2] = [
	Vector2(200, 176),
	Vector2(48, 176)
]

var first_indicator_positions: Array[Vector2] = [
	Vector2(136, 43),
	Vector2(136, 54),
	Vector2(136, 64),
	Vector2(136, 76),
	Vector2(136, 88),
	Vector2(136, 98),
	Vector2(136, 108),
	Vector2(136, 120),
	Vector2(136, 129),
	Vector2(136, 141),
	Vector2(136, 152),
	Vector2(136, 163),
	Vector2(136, 174),
	Vector2(136, 185)
]

var second_indicator_positions: Array[Vector2] = [
	Vector2(264, 43),
	Vector2(264, 54),
	Vector2(264, 64),
	Vector2(264, 76),
	Vector2(264, 88),
	Vector2(264, 98),
	Vector2(264, 108),
	Vector2(264, 120),
	Vector2(264, 129),
	Vector2(264, 141),
	Vector2(264, 152),
	Vector2(264, 163),
	Vector2(264, 174),
	Vector2(264, 185)
]

var jutsus = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if ApiService:
		ApiService.connect("signalApiResponse", process_response)
	#ApiService.login("mafvidal35@gmail.com", "Asd123456+", "LOGIN");
	IDE.connect("executeCodeSignal", sendCode)
	var phrases: Array[String] = [
		"Hola Bitama, Kuzumi quiere robarnos nuestro jutsu maestro",
		"Para ello lo va a buscar en uno de las dos copias de pergaminos que tenemos",
		"Por suerte el solo sabe realizar una busqueda lineal",
		"Debes encontrar el jutsu en el pergamino antes que el y utilizarlo para vencerlo",
		"Vas a tener que realizar una busqueda binaria y asi encontrarlo antes que el",
		"Los jutsus estan identificados con un numero y ordenados, pero no sabemos cual es el buscado",
		"Para ello utiliza la funcion probarJutsu(posicion) para verificar si es el jutsu encontrado en la posicion es el buscado",
		"Puedes utilizar la funcion esMenor(posicion) para verificar si es el jutsu en la posicion es menor al buscado",
		"Puedes utilizar la funcion esMayor(pos) para verificar si es el jutsu en la posicion es mayor al buscado",
		"Vamos apurate y ganale a Kuzumi"
	]
	await show_messages(phrases, master_msg_position)
	player.update_destination(player_first_steps)
	await player.npcArrived
	enemy.update_destination(enemy_first_steps)
	await enemy.npcArrived
	master.update_destination(master_first_steps)
	await master.npcArrived
	set_code()
	phrases = [
		"Recueda utilizar la función probarJutsu(pos) para verificar si es el jutsu buscado",
		"Recueda utilizar la función esMenor(pos) si quieres verificar si el poder del jutsu es menor al buscado",
		"Recueda utilizar la función esMayor(pos) si quieres verificar si el poder del jutsu es mayor al buscado",
	]
	master.update_phrases(phrases, master_msg_position, false, {'auto_play_time': 1, 'close_by_signal': true})

func process_code(res):
	if !executing_code:
		return
	if !res || res["code"] != 200:
		show_error_response(res["message"])
		return;
	var data = res["data"]
	var jutsu = data["expectedResult"]["jutsu"]
	jutsus = data["expectedResult"]["positions"]
	
	if !data["result"] || len(data["result"]) == 0:
		show_no_result_response()
		return
	var result = {
		"enemy": range(len(data["expectedResult"]["positions"])),
		"player": data["result"]
	}
	process_result(result, jutsu)

func process_response(res, extraArg):
	match extraArg:
		"LOGIN": pass
		"COMPLETE_LEVEL": pass
		"ADD_ATTEMPT": pass
		"SEND_CODE": process_code(res)

func set_code():
	var codeLines: Array[String] = [
		"function buscarJutsu(jutsus) {",
		"  //Escribi tu función de busqueda binaria",
		"}"
	]
	IDE.set_code(codeLines)

func show_no_result_response():
	var phrases: Array[String] = [
		"Lo siento discípulo, pero tu algoritmo no encontro ningun jutsu",
		"¡Corrigelo y vuelve a intentarlo!"
	]
	await show_messages(phrases, master_msg_position)
	add_attempt()
	executing_code = false

func show_error_response(error: String):
	var phrases: Array[String] = [
		"Lo siento Bitama, pero no logre ejecutar tu código",
		"Me retorno el siguiente mensaje",
		error,
		"¡Corrigelo y vuelve a intentarlo!"
	]
	await show_messages(phrases, master_msg_position)
	executing_code = false

func show_messages(phrases: Array[String], position: Vector2):
	master.update_phrases(phrases, position, true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog


func win_player():
	complete_level()
	player.update_destination(player_attack_steps)
	await player.npcArrived
	player.attack("right")
	enemy.dead()
	await player.npcFinishAttack
	var phrases: Array[String] = [
		"Felicitaciones lograste vencer a Kuzumi", 
		"Estas listo para una nueva aventura"
	]
	await show_messages(phrases, master_msg_position)
	player.update_destination(player_final_steps)
	


func process_result(result, jutsu):
	for i in range(jutsus.size()):
		if (jutsus[i] == jutsu):
			label.text += ' [color=#3F81E9]['+ str(i) + '][/color]  [color=red]' + str(jutsus[i]) + "[/color]\n"
			label_enemy.text +=  '[color=#3F81E9]['+ str(i) + '][/color] ' + '[color=red]' + str(jutsus[i]) + "[/color]\n"
		else:
			label.text += '  [color=#3F81E9]['+ str(i) + '][/color]  ' + str(jutsus[i]) + "\n"
			label_enemy.text += ' [color=#3F81E9]['+ str(i) + '][/color] ' + str(jutsus[i]) +  "\n"
	label.visible = true
	label_enemy.visible = true
	scroll.visible = true
	var win = true
	var phrases: Array[String] = []
	first_indicator.visible = true
	second_indicator.visible = true
	for i in range(jutsus.size()):
		var index = jutsus.find(result["player"][i])
		var position_first_indicator: Vector2 = first_indicator_positions[result["player"][i]]
		var position_second_indicator: Vector2 = second_indicator_positions[i]
		var final_pos_ind_1: Array[Vector2] = [position_first_indicator]
		var final_pos_ind_2: Array[Vector2] = [position_second_indicator]
		first_indicator.update_destination(final_pos_ind_1)
		await first_indicator.npcArrived
		second_indicator.update_destination(final_pos_ind_2)
		await second_indicator.npcArrived
		var enemy_jutsu = jutsus[i]
		var player_jutsu = jutsus[result["player"][i]]
		phrases = ["Busco en la posicion " + str(result["player"][i]), "Encontre el " + str(player_jutsu)]
		await show_messages(phrases, Vector2(24, 136))
		phrases = ["Busco en la posicion " + str(i), "Encontre el " + str(enemy_jutsu)]
		await show_messages(phrases, Vector2(288, 136))
		if player_jutsu == jutsu:
			break
		if enemy_jutsu == jutsu:
			win = false
			break
	scroll.visible = false
	first_indicator.visible = false
	second_indicator.visible = false
	first_indicator.position = Vector2(136,30)
	second_indicator.position = Vector2(264,30)
	label.visible = false
	label_enemy.visible = false
	if win:
		win_player()
	else:
		add_attempt()

func sendCode(body = null):
	if executing_code:
		return
	executing_code = true
	ApiService.send_request(body, HTTPClient.METHOD_POST, "binary-search", "SEND_CODE")


func add_attempt():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, "score/attempts/vectores/2", "ADD_ATTEMPT")
	
func complete_level():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, "score/complete/vectores/2", "COMPLETE_LEVEL")
