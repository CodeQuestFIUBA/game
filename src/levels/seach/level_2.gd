extends Node2D


@onready var player = $Player
@onready var master = $Master
@onready var IDE = $CanvasLayer/IDE
@onready var map = $TileMap2
var executing_code = false

var open_box = "res://sprites/objects/open_box.png"
var scroll = "res://sprites/objects/scroll.png"

var master_msg_position: Vector2 = Vector2(96, 176)
var box_with_scroll = 4
var potencias = [4,10,2,5,11,8,9]

# Called when the node enters the scene tree for the first time.
func _ready():
	IDE.connect("executeCodeSignal", sendCode)
	var phrases: Array[String] = [
		"Bienvenido discipulo a este nuevo desafio",
		"Como puedes ver nuestros enemigos destruyeron este jardin",
		"Pero por suerte dejaron nuestras posiones intactas",
		"Cada una de estas posiones tiene una potencia para revertir el efecto causado",
		"Sin embargo solo podemos utilizar una y requeriremos de la de mayor potencia",
		"Yo se la potencia de cada posion, pero nuestros enemigos me lastimaron y no puedo buscar una por una",
		"Escribe el codigo tal que revises uno a uno las posiciones",
		"Preguntame mediante la funcion indicameLaPotencia(indice)",
		"Y si la potencia es la mayor encontrada hasta el momento avisame mediante la funcion encontreUnaMaxima(potencia)",
		"De tal forma que te quedes con la de mayor potencia"
	]
	await show_messages(phrases, master_msg_position)
	set_code()



func set_code():
	var codeLines: Array[String] = [
		"//Funcion que retorna el valor de la potencia de la fuente dado el indice",
		"//indicameLaPotencia(indice)",
		"//Funcion que le avisa al maestro si la potencia encontrada es la mayor hasta el momento",
		"//encontreUnaMaxima(potencia)",
		"var totalDePosicione = 7",
		"var maximaPotencia = 0;",
		"for (var indice = 0; ; indice++) {",
		"	var potencia = indicameLaPotencia(indice);",
		"}"
	]
	IDE.set_code(codeLines)

func show_messages(phrases: Array[String], position: Vector2):
	master.update_phrases(phrases, position, true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog


func get_posion_steps(index: int) -> Array[Vector2]:
	match index:
		0: return [
				Vector2(56, 168),
				Vector2(56, 120)
			]
		1: return [
				Vector2(56, 144),
				Vector2(152, 144),
				Vector2(152, 120)
			]
		2: return [
				Vector2(152, 144),
				Vector2(248, 144),
				Vector2(248, 120)
			]
		3: return [
				Vector2(248, 144),
				Vector2(344, 144),
				Vector2(344, 120)
			]
		4: return [
				Vector2(344, 144),
				Vector2(312, 144),
				Vector2(312, 40)
			]
		5: return [
				Vector2(312, 64),
				Vector2(216, 64),
				Vector2(216, 40)
			]
		_: return [
				Vector2(216, 64),
				Vector2(104, 64),
				Vector2(104, 40)
			]


func process_result(result):
	var masterPhrases: Array[String] = []
	var playerPhrases: Array[String] = []
	var maxIndex = 0
	var max = 0
	for i in range(result["potencias"].size()):
		var steps: Array[Vector2] = get_posion_steps(i);
		player.update_destination(steps)
		await player.npcArrived
		var indice = result["indices"][i]
		var bottle = result["potencias"][i]
		playerPhrases = ["El valor de la botella es " + str(indice)]
		masterPhrases = ["El potencia es " + str(bottle)]
		await show_messages(playerPhrases, Vector2(56, 152))
		await show_messages(masterPhrases, master_msg_position)
		if maxIndex < result["potenciasInformadas"].size() && result["potenciasInformadas"][maxIndex] == bottle:
			maxIndex += 1
			max = bottle
			playerPhrases = ["Esa es la mayor potencia encontrada hasta el momento"]
		else:
			playerPhrases = ["No es la maxima potencia"]
		await show_messages(playerPhrases, Vector2(56, 152))
	playerPhrases = ["La maxima potencia que encontre es " + str(max)]
	await show_messages(playerPhrases, Vector2(56, 152))
	masterPhrases = ["Muy bien, es correcto ahora vamos a utilizarla para recuperar este jardin"]
	await show_messages(masterPhrases, master_msg_position)
	map.visible = true
	masterPhrases = ["Muy bien, completamos este desafio. Es hora de seguir con el proximo"]
	await show_messages(masterPhrases, master_msg_position)


func sendCode(code):
	if executing_code:
		return
	executing_code = true
	var result = {
		"indices": [0,3,5,4,6,2,1],
		"potencias": [4,10,2,5,11,8,9],
		"potenciasInformadas": [4,10,11]
	}
	#le paso las armas a la api
	process_result(result)
