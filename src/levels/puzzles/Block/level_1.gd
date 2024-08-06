extends Node2D

@onready var npcExplainer = $npcExplainer;
@onready var ninja = $Ninja
@onready var blockTarget = $BlockTarget
@onready var mainButton = $PlayButton
var nextLevel = "res://levels/puzzles/Block/level_2.tscn"
const solution = [
	{"value" : "Mover Arriba","target": Vector2(95,160) },
	{"value" : "Mover Izquierda", "target": Vector2(15,157) },
	{"value": "Mover Arriba", "target": Vector2(15,112) },
	{"value": "Mover Derecha", "target": Vector2(153,112) },
	{"value": "Mover Arriba", "target": Vector2(153,62) },
	{"value" : "Mover Izquierda", "target": Vector2(50,62) },
	{"value": "Mover Arriba", "target": Vector2(48,30) },
]

func _ready():
	$moveDown.setAction("Mover Abajo")
	$moveUp.setAction("Mover Arriba")
	$moveLeft.setAction("Mover Izquierda")
	$moveRight.setAction("Mover Derecha")
	start_Level()

func _on_play_button_pressed():
	validate_instructions()

func start_Level () :
	load_introduction_dialogs()

func load_introduction_dialogs():
	const intruction_dialogs : Array[String] = [
		"Hola Bitama !",
		"Para comenzar tu camino Ninja ..",
		".. introducimos el concepto de algoritmo",
		"Un Algoritmo es una secuencia...",
		"...finita de instrucciones",
		"... con el fin de realizar una tarea.",
		"Teniendo esto en cuenta, ...",
		"Llega al aldeano sin tocar el agua"
		
	]
	talk_as_master(intruction_dialogs)

func validate_instructions():
	var inserted_elements = blockTarget.getPuzzle()
	var inserted_len = len(inserted_elements)
	var solution_len = len(solution)
	if (inserted_len > solution_len):
		talk_as_master([".MMMMM","Creo que estas poniendo instrucciones demás"])
	elif (solution_len > inserted_len):
		talk_as_master([".MMMMM","Creo que te faltan algunas instrucciones ..."])
	elif ( is_valid_solution(inserted_elements) ):
		talk_as_master(["Siiiii ...", "Con ese camino no estas pisando el agua!"])
		caminar_a_objectivo()
	else:
		talk_as_master([".MMMM", "Esa combinación no es válida..", "... Fijate bien :("])

func talk_as_master(dialogs :Array[String]):
	npcExplainer.update_phrases(dialogs,Vector2(185, 45),true, {'auto_play_time': 1, 'close_by_signal':true})

func is_valid_solution(inserted : Array) -> bool :
	for x in len (solution) :
		if (inserted[x] != solution[x]["value"] ):
			return false
	return true

func caminar_a_objectivo():
	var positions: Array[Vector2] = []
	for x in solution :
		positions.append(x["target"])
	ninja.update_destination(positions)
	mainButton.disabled = true
	await ninja.npcArrived
	complete_level()
	next()


func complete_level():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, "score/complete/introduction/0", "COMPLETE_LEVEL")


func next():
	LevelManager.load_scene(get_tree().current_scene.scene_file_path, nextLevel)

