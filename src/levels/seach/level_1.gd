extends Node2D


@onready var player = $Player
@onready var master = $Master
@onready var IDE = $CanvasLayer/IDE
var executing_code = false
var nextLevel = "res://levels/seach/level_2.tscn"

var open_box = "res://sprites/objects/open_box.png"
var scroll = "res://sprites/objects/scroll.png"

var master_msg_position: Vector2 = Vector2(104, 176)
var box_with_scroll = 4

var player_positions: Array[Vector2] = [
	Vector2(72, 88),
	Vector2(104,88),
	Vector2(136,88),
	Vector2(168,88),
	Vector2(200,88),
	Vector2(232,88),
	Vector2(264,88),
	Vector2(296,88),
	Vector2(328,88)
]

var box_positions: Array[Vector2] = [
	Vector2(72, 72),
	Vector2(104,72),
	Vector2(136,72),
	Vector2(168,72),
	Vector2(200,72),
	Vector2(232,72),
	Vector2(264,72),
	Vector2(296,72),
	Vector2(328,72)
]

var intialPosition: Array[Vector2] = [
	Vector2(200,160)
]

var finalPosition: Array[Vector2] = [
	Vector2(256,240)
]


# Called when the node enters the scene tree for the first time.
func _ready():
	ApiService.connect("signalApiResponse", process_response)
	IDE.connect("executeCodeSignal", sendCode)
	var phrases: Array[String] = [
		"Hola Bitama",
		"Es hora de aprender busquedas",
		"Tienes 9 bibliotecas con pergaminos",
		"Debes buscar el pergamino 'Ataques devastadores' para poder vencer a Kuzumi"
	]
	await show_messages(phrases, master_msg_position)
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
		"Recuerda retornar el índice y no el valor...",
		"Busca las palabras 'Ataques devastadores'...",
		"Recuerda que el índice inicia en cero..."
	]
	master.update_phrases(phrases, master_msg_position, false, {'auto_play_time': 1, 'close_by_signal': true})


func set_code():
	var codeLines: Array[String] = [
		"function funcion(pergaminos) {",
		"    var pergamino = 'Ataques devastadores'';",
		"    ",
		"    ",
		"    ",
		"}"
	]
	IDE.set_code(codeLines)

func show_messages(phrases: Array[String], position: Vector2):
	master.update_phrases(phrases, position, true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog


func load_texture(texture: String, box_position: Vector2, isScroll: bool):
	var sprite = Sprite2D.new()
	sprite.position = Vector2(box_position)
	if isScroll:
		sprite.scale.x = 0.7
		sprite.scale.y = 0.7
	sprite.z_index = 6
	sprite.texture = ResourceLoader.load(texture)
	add_child(sprite)


func get_posion_steps(index: int) -> Array[Vector2]:
	match index:
		0: return [
				Vector2(184, 128),
				Vector2(40, 128),
				Vector2(40, 112)
			]
		1: return [
				Vector2(72, 112),
				Vector2(72, 80)
			]
		2: return [
				Vector2(120, 80),
				Vector2(120, 64)
			]
		3: return [
				Vector2(168, 64),
				Vector2(168, 48)
			]
		4: return [
				Vector2(232, 48)
			]
		5: return [
				Vector2(232, 64),
				Vector2(280, 64)
			]
		6: return [
				Vector2(280, 80),
				Vector2(328, 80)
			]
		_: return [
				Vector2(328, 112),
				Vector2(360, 112)
			]

func process_result(result):
	var pergaminos = result["pergaminos"]
	var posicionPergamino: int = result["posicionPergamino"]
	var index: int = result["index"]
	print("Frases")
	for i in range(pergaminos.size()):
		var steps: Array[Vector2] = get_posion_steps(i)
		player.update_destination(steps)
		await player.npcArrived
		var masterPhrases: Array[String] = [
			"El pergamino es " + pergaminos[i]
		]
		await show_message(masterPhrases)
		if index == i:
			masterPhrases = [
				"Este es el pergamino buscado"
			]
			await show_message(masterPhrases)
		if i == posicionPergamino:
			break
	if index == posicionPergamino:
		finish_game()
	else:
		restart()


func finish_game():
	complete_level()
	var masterPhrases: Array[String] = [
		"Muy bien Bitama, encontraste el pergamino...",
		"Ahora podremos enfrentarnos a Kuzumi..."
	]
	await show_message(masterPhrases)
	player.update_destination(finalPosition)
	await player.npcArrived
	next()


func restart():
	add_attempt()
	var masterPhrases: Array[String] = [
		"Lo siento Bitama ese el pergamino ",
		"Volvamos a intentarlo"
	]
	await show_message(masterPhrases)
	player.update_destination(intialPosition)
	await player.npcArrived
	executing_code = false
	loadHelp()

func sendCode(code):
	if executing_code:
		return
	executing_code = true
	ApiService.send_request(code, HTTPClient.METHOD_POST, "vectors/lineal", "SEND_CODE")

func add_attempt():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, "score/attempts/vectores/0", "ADD_ATTEMPT")
	
func complete_level():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, "score/complete/vectores/0", "COMPLETE_LEVEL")


func next():
	LevelManager.load_scene(get_tree().current_scene.scene_file_path, nextLevel)
