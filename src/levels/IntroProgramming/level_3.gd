extends Node2D


@onready var player = $player
@onready var master = $master
@onready var IDE = $CanvasLayer/IDE
@onready var first_guardian = $first_guradian
@onready var second_guardian = $second_guradian

var firts_setps: Array[Vector2] = [ Vector2(32,128), Vector2(128,128)]

var first_steps_up: Array[Vector2] = [ Vector2(128,88), Vector2(216,88), Vector2(224,128), Vector2(240,128)]
var first_steps_down: Array[Vector2] = [ Vector2(128, 168), Vector2(224,168), Vector2(224,128), Vector2(240,128)]

var second_steps_up: Array[Vector2] = [ Vector2(240,88), Vector2(344,88), Vector2(344,136), Vector2(392,136)]
var second_steps_down: Array[Vector2] =  [ Vector2(240,168), Vector2(344,168), Vector2(344,136), Vector2(392,136)]


var first_guardian_steps_up: Array[Vector2] = [ Vector2(192, 88), Vector2(160, 88)]
var first_guardian_steps_down: Array[Vector2] = [ Vector2(192, 168), Vector2(160, 168)]

var second_guardian_steps_up: Array[Vector2] = [ Vector2(304, 88), Vector2(272, 88)]
var second_guardian_steps_down: Array[Vector2] = [ Vector2(304, 168), Vector2(272, 168)]

var executing_code = false

# Called when the node enters the scene tree for the first time.
func _ready():
	IDE.connect("executeCodeSignal", sendCode)
	var phrases: Array[String] = [
		"Hola vamos a aprender el if else",
		"El if te permite segun una condicion ejuctar un flujo de codigo",
		"En este caso vamos a utilizarlo para pasar frente a nuestros guaridas y que no nos descubran",
		"Tu objetivo es pasar por estas dos puertas esquivando a los guaridas",
		"Un ninja aliado nos dio dos mensajes sobre la posicion de los guaridas",
		"El mensaje tendra el valor 'arriba' o 'abajo' segun la puerta donde se encuentra el guardia",
		"Deberas guardar en cada variable 'puerta' los valores 'arriba' o de 'abajo' segun la puerta que debes ir",
		"Para eso utilizaras el 'if else' con el valor con los mensajes de nuestro aliado"
	]
	await show_master_messages(phrases)
	var codeLines: Array[String] = ["var puerta_1;","var puerta_2;" ,"if (mensaje_1 === \"arriba\") {", "	//guardar el valor \"arriba\" o \"abajo\"", "	puerta_1 = \"\"", "} else {", "	//completar con el caso opuesto", "}", "	puerta_1 = \"\"", "if (mensaje_2 === \"abajo\") {", "	//completar...", "	puerta_2 = \"\"", "} else {", "	puerta_2 = \"\"", "}"]
	IDE.set_code(codeLines)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func show_master_messages(phrases: Array[String]):
	master.update_phrases(phrases, Vector2(80,48), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog


func test_result():
	pass
	
	
func process_result():
	player.update_destination(firts_setps)
	await player.npcArrived
	first_guardian.update_destination(first_guardian_steps_down)
	await first_guardian.npcArrived
	player.update_destination(first_steps_up)
	await player.npcArrived
	second_guardian.update_destination(second_guardian_steps_up)
	await second_guardian.npcArrived
	player.update_destination(second_steps_down)
	await player.npcArrived


func sendCode(code):
	if executing_code:
		return
	executing_code = true
	#le paso las armas a la api
	test_result()
	process_result()
