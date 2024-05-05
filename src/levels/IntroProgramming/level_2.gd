extends Node2D

@onready var player = $Player
@onready var master = $Master
@onready var IDE = $CanvasLayer/IDE
@onready var door_1 = $Door_1
@onready var door_2 = $Door_2
@onready var door_3 = $Door_3


var door_1_steps: Array[Vector2] = [ Vector2(72,40)]
var door_2_setps: Array[Vector2] = [ Vector2(200,40)]
var door_3_setps: Array[Vector2] = [ Vector2(312,40)]


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


func set_code():
	var codeLines: Array[String] = [
		"//Funcion que emite el saludo al maestro",
		"//saludarAlMaestro()",
		"",
		"//Funcion que retorna un numero de puerta",
		"//obtenerNumeroDePuerta()",
		"",
		"//Funcion que recibe como parametro el numero de puerta ",
		"//abrirPuerta(puerta)"
	]
	IDE.set_code(codeLines)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func show_master_messages(phrases: Array[String]):
	master.update_phrases(phrases, Vector2(72, 184), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog


func process_result(result):
	if !result["hi"] || !result['door'] || !result["opened_door"] || result["opened_door"] != result['door'] :
		show_error_messages(result)
		return
	var phrases: Array[String] = [
		"Hola maestro, estoy feliz de ser su discipulo"
	]
	player.update_phrases(phrases, Vector2(192, 184), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	if result["opened_door"] == 1:
		door_1.visible = false
	elif result["opened_door"] == 2:
		door_2.visible = false
	else:
		door_3.visible = false
	phrases = [
		"Bien hecho mi discipulo, completaste el desafio",
		"Ahora puedes ir por esa puerta y seguir tu aventura"
	]
	await show_master_messages(phrases)
	if result["opened_door"] == 1:
		player.update_destination(door_1_steps)
	elif result["opened_door"] == 2:
		player.update_destination(door_2_setps)
	else:
		player.update_destination(door_3_setps)
	await player.npcArrived


func show_error_messages(result):
	var phrases: Array[String] = []
	if !result["hi"]:
		phrases = [
			"Debes llamar correctamente a la funcion de saludarAlMaestro()"
		]
	elif !result["door"]:
		phrases = [
			"Debes llamar correctamente a la funcion de obtenerNumeroDePuerta()"
		]
	elif !result["opened_door"]:
		phrases = [
			"Debes llamar correctamente a la funcion de abrirPuerta(puerta)"
		]
	else:
		phrases = [
			"El valor obtenido de obtenerNumeroDePuerta() se lo debes pasar a la funcion abrirPuerta(puerta)"
		]
	await show_master_messages(phrases)
	executing_code = false
	set_code()

func sendCode(code):
	if executing_code:
		return
	executing_code = true
	var result = {
		"hi": true,
		"door": 2,
		"opened_door": 2
	}
	#le paso las armas a la api
	process_result(result)
