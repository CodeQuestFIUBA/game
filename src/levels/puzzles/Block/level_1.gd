extends Node2D

@onready var npcExplainer = $npcExplainer;
@onready var ninja = $Ninja
@onready var blockTarget = $BlockTarget
@onready var mainButton = $PlayButton

const solution = [
	{"value" : "Mover Arriba","target": Vector2(95,161) },
	{"value" : "Mover Izquierda", "target": Vector2(34,157) },
	{"value": "Mover Arriba", "target": Vector2(33,96) },
	{"value": "Mover Derecha", "target": Vector2(127,93) },
	{"value": "Mover Arriba", "target": Vector2(126,48) },
	{"value" : "Mover Izquierda", "target": Vector2(47,45) },
	{"value": "Mover Arriba", "target": Vector2(48,30) },
]

func _ready():
	$moveDown.setAction("Mover Abajo")
	$moveUp.setAction("Mover Arriba")
	$moveLeft.setAction("Mover Izquierda")
	$moveRight.setAction("Mover Derecha")
	start_Level()
	
	
	ModalManager.open_modal({
		'title': "Titulito",
		'description': "Esta es una description de lo que me esta diciendo este modal ...",
		'title_font_size': 12,
		'description_font_size': 9,
		'primary_button_label': "Aceptar",
		'secondary_button_label': "Cancelar"
		})
		
	ModalManager.on_modal_primary_pressed.connect(handle_primary_click)
	ModalManager.on_modal_secondary_pressed.connect(handle_secondary_click)
	
	ModalManager.close_modal()
	
	

func _on_play_button_pressed():
	validate_instructions()
	ModalManager.open_modal()
	ModalManager.on_modal_secondary_pressed.connect(handle_secondary_click)

func handle_primary_click () :
	print("apreto el boton primario")
	
func handle_secondary_click () :
	print ("apreto el boton secundario")

func start_Level () :
	load_introduction_dialogs()

func load_introduction_dialogs():
	const intruction_dialogs : Array[String] = [
		"Hola!!!",
		"El siguiente paso en tu camino ..",
		".. es una tarea muy simple",
		"Encastra los bloques para llegar al aldeano",
		"POR FAVOR NO PISES EL CESPED",
		"Desde la nevada de 2007 que vengo renegando"
	]
	talk_as_master(intruction_dialogs)

func validate_instructions():
	var inserted_elements = blockTarget.getPuzzle()
	var inserted_len = len(inserted_elements)
	var solution_len = len(solution)
	if (inserted_len > solution_len):
		talk_as_master([".MMMMM","Creo que estas poniendo instrucciones de mas"])
	elif (solution_len > inserted_len):
		talk_as_master([".MMMMM","Creo que te faltan algunas instrucciones ..."])
	elif ( is_valid_solution(inserted_elements) ):
		talk_as_master(["Siiiii ...", "Con ese camino no pisarias el pasto"])
		caminar_a_objectivo()
	else:
		talk_as_master([".MMMM", "Esa combinacion no es valida..", "... Fijate bien :("])
	


func talk_as_master(dialogs :Array[String]):
	DialogManager.start_dialog(Vector2(152,30),dialogs, {'auto_play_time': 0.7})

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
