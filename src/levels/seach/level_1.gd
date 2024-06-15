extends Node2D


@onready var player = $Player
@onready var master = $Master
@onready var IDE = $CanvasLayer/IDE
var executing_code = false

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


# Called when the node enters the scene tree for the first time.
func _ready():
	IDE.connect("executeCodeSignal", sendCode)
	var phrases: Array[String] = [
		"Hola discipulo",
		"Es hora de aprender busquedas",
		"Tienes 9 cajas y una tiene el pergamino",
		"Deberas escrbir un algorimo que busque desde la primer caja de forma lineal, hasta encontrar el pergamino",
		"Podras utilizar la funcion tienePergamino(indice)"
	]
	await show_messages(phrases, master_msg_position)
	set_code()



func set_code():
	var codeLines: Array[String] = [
		"//Funcion que retorna true o false segun si la caja tiene el pergamino",
		"//tienePergamino(indice)"
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
	

func process_result(result: int):
	var foundScroll = result == box_with_scroll
	for i in range(9):
		var player_position: Vector2 = player_positions[i]
		var final_position: Array[Vector2] = [player_position]
		print(final_position)
		player.update_destination(final_position)
		await player.npcArrived
		load_texture(open_box, box_positions[i], false)
		if i == box_with_scroll:
			load_texture(scroll, box_positions[i], true)
		var phrases: Array[String] = []
		if result != i:
			phrases = ["En esta caja no se encuentra el pergamino, seguire buscando en la siguiente"]
		else:
			phrases = ["En esta caja se encuentra el pergamino"]
		var message_position: Vector2 = Vector2(72,104)
		await show_messages(phrases, message_position)
		if result == i || i == box_with_scroll:
			break
	var master_phrases: Array[String] = []
	if foundScroll:
		master_phrases = [
			"Muy bien discipulo, encontraste el pergamino", 
			"Ahora puedes seguir con el siguiente desafio"
		]
	else:
		master_phrases = [
			"Lo siento, el pergamino no se encontraba ahi", 
			"Volvamos a intentarlo"
		]
	await show_messages(master_phrases, master_msg_position)

func sendCode(code):
	if executing_code:
		return
	executing_code = true
	var result = 4
	#le paso las armas a la api
	process_result(result)
