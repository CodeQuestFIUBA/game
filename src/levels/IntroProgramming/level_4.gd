extends Node2D


@onready var player = $Player
@onready var master = $Master
@onready var IDE = $CanvasLayer/IDE
@onready var copy_1 = $Copy1
@onready var copy_2 = $Copy2
@onready var copy_3 = $Copy3
@onready var copy_4 = $Copy4

var executing_code = false

# Called when the node enters the scene tree for the first time.
func _ready():
	IDE.connect("executeCodeSignal", sendCode)
	var phrases: Array[String] = [
		"Mensajes introductorios a funciones",
		"...",
		"Mas lo que tiene que hacer",
		"..."
	]
	await show_master_messages(phrases)
	set_code()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_code():
	var codeLines: Array[String] = [
		"//Funcion que retorna la cantidad de copias pedidas por el maestro",
		"//obtenerTotalDeCopias()",
		"",
		"//Funcion que permite generar una copia de mi mismo",
		"//generarCopia()",
		"",
		"//Completar condiciones de corte del for",
		"for (var i = 0;  ; i++) {",
		"	//llamar a la funcion de generar copia",
		"}"
	]
	IDE.set_code(codeLines)

func show_master_messages(phrases: Array[String]):
	master.update_phrases(phrases, Vector2(96, 160), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog

func show_copy(index: int):
	match index:
		0: copy_1.visible = true
		1: copy_2.visible = true
		2: copy_3.visible = true
		_: copy_4.visible = true

func process_result(result):
	var phrases: Array[String] = ["Realizo copia"]
	for i in range(result["total_copies"]):
		player.update_phrases(phrases, Vector2(184,176), true, {'auto_play_time': 1, 'close_by_signal': true})
		await DialogManager.signalCloseDialog
		show_copy(i)
	phrases = [
		"Bien hecho mi discipulo, completaste el desafio",
		"Ahora puedes ir por esa puerta y seguir tu aventura"
	]
	await show_master_messages(phrases)
	

func sendCode(code):
	if executing_code:
		return
	executing_code = true
	var result = {
		"total_copies": 4
	}
	#le paso las armas a la api
	process_result(result)
