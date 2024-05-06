extends Node2D


@onready var player = $Player
@onready var master = $Master
@onready var enemy = $Enemy
@onready var IDE = $CanvasLayer/IDE
@onready var first_indicator = $FirstIndicator
@onready var second_indicator = $SecondIndicator
@onready var scroll = $TileMap2
@onready var label = $Label
@onready var label_enemy = $Label2
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
	Vector2(136, 40),
	Vector2(136, 50),
	Vector2(136, 60),
	Vector2(136, 72),
	Vector2(136, 83),
	Vector2(136, 94),
	Vector2(136, 105),
	Vector2(136, 116),
	Vector2(136, 127),
	Vector2(136, 138),
	Vector2(136, 149),
	Vector2(136, 160),
	Vector2(136, 171),
	Vector2(136, 182)
]

var second_indicator_positions: Array[Vector2] = [
	Vector2(264, 40),
	Vector2(264, 50),
	Vector2(264, 60),
	Vector2(264, 72),
	Vector2(264, 83),
	Vector2(264, 94),
	Vector2(264, 105),
	Vector2(264, 116),
	Vector2(264, 127),
	Vector2(264, 138),
	Vector2(264, 149),
	Vector2(264, 160),
	Vector2(264, 171),
	Vector2(264, 182)
]

var jutsus = [5,12,13,23,25,30,33,38,42,47,60,72,88,90]

# Called when the node enters the scene tree for the first time.
func _ready():
	IDE.connect("executeCodeSignal", sendCode)
	var phrases: Array[String] = [
		"Hola discipulo, nuestro enemigo quiere robarnos nuestro jutsu maestro",
		"Para ello lo va a buscar en uno de las dos copias de pergaminos que tenemos",
		"Por suerte el solo sabe realizar una busqueda lineal",
		"Debes encontrar el jutsu en el pergamino antes que el y utilizarlo para vencerlo",
		"Vas a tener que realizar una busqueda binaria y asi encontrarlo antes que el",
		"Para ello utiliza la funcion obtenerJutsus() que te retornara un vector con todas los jutsus del pergamino",
		"Los jutsus estan identificados con un numero y el que estamos buscando es el numero 47",
		"El pergamino tiene los jutsus ordenados, pero para evitar que nuestros enemigos lo obtengan varios fueron eliminados",
		"Vamos apurate y encuentralo antes que el"
	]
	await show_messages(phrases, master_msg_position)
	player.update_destination(player_first_steps)
	await player.npcArrived
	enemy.update_destination(enemy_first_steps)
	await enemy.npcArrived
	master.update_destination(master_first_steps)
	await master.npcArrived
	set_code()



func set_code():
	var codeLines: Array[String] = [
		"//Funcion que retorna un vector con los identificadores de jutsus",
		"//obtenerJutsus()",
		"var jutsus = obtenerJutsus();",
		"var jutsuBuscado = 47;",
		"//Escibir el algoritmo de busqueda binaria iterando el vector de jutsus hasta encontrar el jutsuBuscado 47"
	]
	IDE.set_code(codeLines)

func show_messages(phrases: Array[String], position: Vector2):
	master.update_phrases(phrases, position, true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog


func win_player():
	player.update_destination(player_attack_steps)
	await player.npcArrived
	player.attack("right")
	enemy.dead()
	await player.npcFinishAttack
	var phrases: Array[String] = [
		"Felicitaciones lograste vencer a nuestro enemigo", 
		"Estas listo para una nueva aventura"
	]
	await show_messages(phrases, master_msg_position)
	player.update_destination(player_final_steps)
	


func process_result(result):
	for i in range(jutsus.size()):
		label.text += '  ' + str(jutsus[i]) + "\n"
		label_enemy.text += '' + str(jutsus[i]) + "\n"
	label.visible = true
	label_enemy.visible = true
	scroll.visible = true
	var jutsu = 47
	var win = true
	var phrases: Array[String] = []
	for i in range(jutsus.size()):
		var index = jutsus.find(result["player"][i])
		first_indicator.position = first_indicator_positions[result["player"][i]]
		second_indicator.position = second_indicator_positions[i]
		first_indicator.visible = true
		second_indicator.visible = true
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
	label.visible = false
	label_enemy.visible = false
	if win:
		win_player()

func sendCode(code):
	if executing_code:
		return
	executing_code = true
	var result = {
		"enemy": [0,1,2,3,4,5,6,7,8,9],
		"player": [6, 10, 8, 9]
	}
	#le paso las armas a la api
	process_result(result)

