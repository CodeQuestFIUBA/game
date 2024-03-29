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

func _on_play_button_pressed():
	var positions: Array[Vector2] = []
	for x in solution :
		positions.append(x["target"])
	ninja.update_destination(positions)

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
	DialogManager.start_dialog(Vector2(152,30),intruction_dialogs, {'auto_play_time': 0.7})
