extends Node2D

@onready var npcExplainer = $npcExplainer;
@onready var ninja = $Ninja
@onready var blockTarget = $BlockTarget
@onready var mainButton = $PlayButton
@onready var boat = $Boat
var nextLevel = "res://levels/puzzles/Block/level_3.tscn"

signal boatArrivedPort

const solution = [
	{"value" : "Mover Arriba","target": Vector2(248,54) },
	{"value" : "Mover Izquierda", "target": Vector2(200,52) },
	{"value": "IF(bote_en_puerto)", "target": Vector2(15,112) },
	{"value": "Subir al Bote", "target": Vector2(153,112) },
	{"value": "END IF", "target": Vector2(153,62) },
	{"value" : "Mover Izquierda", "target": Vector2(50,62) },
]

func _ready():
	$moveDown.setAction("Mover Abajo")
	$moveUp.setAction("Mover Arriba")
	$moveLeft.setAction("Mover Izquierda")
	$moveRight.setAction("Mover Derecha")
	$subirAlBote.setAction("Subir al Bote")
	$if.setAction("IF(bote_en_puerto)")
	$endIf.setAction("END IF")
	start_Level()

func _on_play_button_pressed():
	validate_instructions()

func start_Level () :
	load_introduction_dialogs()
	set_boat_positions()

func load_introduction_dialogs():
	const intruction_dialogs : Array[String] = [
	"¡Hola Bitama!",
	"En esta sección vamos a ver los condicionales, ¿te suena?",
	"Un condicional te deja tomar decisiones en tu programa.",
	"Es como decirle al programa: 'Si pasa esto, entonces hacé esto otro.'",
	"En este caso, tenés que esperar a que el bote esté en la orilla para tomarlo.",
	"Para eso, vas a usar el operador IF y luego vas a cerrar la acción con el operador END IF.",
	"Te espero en esta plataforma para continuar nuestra aventura."
	]
	talk_as_master(intruction_dialogs)

func set_boat_positions():
	boat.setPositions([Vector2(177, 57), Vector2(64, 25)]);
	boat.start();

func validate_instructions():
	var inserted_elements = blockTarget.getPuzzle()
	var inserted_len = len(inserted_elements)
	var solution_len = len(solution)
	if (inserted_len > solution_len):
		talk_as_master([".MMMMM","Creo que estas poniendo instrucciones demás"])
	elif (solution_len > inserted_len):
		talk_as_master([".MMMMM","Creo que te faltan algunas instrucciones ..."])
	elif ( is_valid_solution(inserted_elements) ):
		talk_as_master(["Siiiii ...", "Con ese camino no te caes al agua!!"])
		mover_a_objectivo()
	else:
		talk_as_master([".MMMM", "Esa combinación no es válida..", "... Fijate bien :("])

func talk_as_master(dialogs :Array[String]):
	npcExplainer.update_phrases(dialogs,Vector2(30, 15),true, {'auto_play_time': 1, 'close_by_signal':true})

func is_valid_solution(inserted : Array) -> bool :
	for x in len (solution) :
		if (inserted[x] != solution[x]["value"] ):
			return false
	return true

func mover_a_objectivo():
	mainButton.disabled = true
	#Las 2 primeras posiciones son para mover el jugador.
	var positions : Array[Vector2] = []
	for x in solution.slice(0,2) :
		positions.append(x["target"])
	ninja.update_destination(positions)
	#Hay que esperar a que llegue
	await boatArrivedPort
	boat.put_ninja_on_board()
	ninja.hide()
	ninja.set_position(Vector2(40,18))
	await boat.onArrival
	boat.remove_ninja_on_board()
	ninja.show()
	positions = [Vector2(29,19)]
	ninja.update_destination(positions)
	await ninja.npcArrived
	complete_level()
	next()

func _on_boat_on_arrival(pos):
	boat.stop()
	print(boat.actual_target)
	if (boat.actual_target == 0) :
		boatArrivedPort.emit()
	await get_tree().create_timer(2.0).timeout
	boat.start()


func complete_level():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, "score/complete/introduction/1", "COMPLETE_LEVEL")



func next():
	get_tree().change_scene_to_file(nextLevel)
