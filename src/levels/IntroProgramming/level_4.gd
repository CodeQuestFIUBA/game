extends Node2D


@onready var player = $Player
@onready var master = $Master
@onready var IDE = $CanvasLayer/IDE
@onready var copy_1 = $Copy1
@onready var copy_2 = $Copy2
@onready var copy_3 = $Copy3
@onready var copy_4 = $Copy4
var nextLevel = "res://levels/IntroProgramming/level_5.tscn"

var master_msg_position = Vector2(96, 160)
var executing_code = false

var final_steps: Array[Vector2] = [ Vector2(360,120), Vector2(360,152), Vector2(416,152)]

# Called when the node enters the scene tree for the first time.
func _ready():
	if ApiService:
		ApiService.connect("signalApiResponse", process_response)
	#ApiService.login("mafvidal35@gmail.com", "Asd123456+", "LOGIN");
	IDE.connect("executeCodeSignal", sendCode)
	IDE.connect("executeCodeSignal", sendCode)
	var phrases: Array[String] = [
		"Hola Bitama, por fin un poco de tranquilidad…",
		"Te voy a enseñar una nueva técnica, que te va a ser muy útil para enfrentarte a nuestros enemigos…",
		"Es la técnica de clonación, permite realizar copias de ti mismo para ayudarte a pelear…",
		"Para practicar te dire un número y deberás realizar esa cantidad de copias…",
		"¡¡¡Vamos a practicarlo!!!"
	]
	await show_master_messages(phrases)
	set_code()
	loadHelp()


func loadHelp():
	var phrases: Array[String] = [
		"Recueda utilizar la función getCantidadDeCopias() para obtener las cantidad de copias",
		"Utiliza esa cantidad como condición de corte del ciclo for",
		"Recueda utilizar la función generarCopia() para realizar una copia tuya",
		"Llama a la función generarCopia() dentro del ciclo for",
		"Cuidado con los limites del for..."
	]
	master.update_phrases(phrases, master_msg_position, false, {'auto_play_time': 1, 'close_by_signal': true})


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func process_response(res, extraArg):
	match extraArg:
		"LOGIN": pass
		"COMPLETE_LEVEL": pass
		"ADD_ATTEMPT": pass
		"SEND_CODE": 
			if !res || res["code"] != 200:
				show_error_response(res["message"])
				return;
			process_result(res["data"]["result"])

func show_error_response(error: String):
	var phrases: Array[String] = [
		"Lo siento Bitama, pero no logre ejecutar tu código",
		"Me retorno el siguiente mensaje",
		error,
		"¡Corrigelo y vuelve a intentarlo!"
	]
	master.update_phrases(phrases, master_msg_position, true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	executing_code = false
	loadHelp()

func set_code():
	var codeLines: Array[String] = [
		"//Funcion que retorna la cantidad de copias pedidas por el maestro",
		"//getCantidadDeCopias()",
		"",
		"//Funcion que permite generar una copia de mi mismo",
		"//generarCopia()"
	]
	IDE.set_code(codeLines)

func show_master_messages(phrases: Array[String]):
	master.update_phrases(phrases, master_msg_position, true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog

func show_copy(index: int):
	match index:
		0: copy_1.visible = true
		1: copy_2.visible = true
		2: copy_3.visible = true
		_: copy_4.visible = true

func hide_copies():
	copy_1.visible = false
	copy_2.visible = false
	copy_3.visible = false
	copy_4.visible = false

func process_result(result):
	var phrases: Array[String] = [
		"Bien inciemos, realiza " + str(result["copias"]) + " copias",
		"Ok maestro, realizare " + str(result["copiasUsuario"]) + " copias"
	]
	await show_master_messages(phrases)
	if result["copias"] != result["copiasUsuario"]:
		show_error_messages()
		return
	phrases = ["¡Realizo una copia!"]
	for i in range(result["copiasUsuario"]):
		player.update_phrases(phrases, Vector2(184,176), true, {'auto_play_time': 1, 'close_by_signal': true})
		await DialogManager.signalCloseDialog
		show_copy(i)
	phrases = [
		"Bien hecho Bitama...",
		"Aprendiste la tecnica de clonación...",
		"Ahora puedes seguir para enfrentar el ultimo desafio antes de JR..."
	]
	complete_level()
	await show_master_messages(phrases)
	hide_copies()
	player.update_destination(final_steps)
	await player.npcArrived
	next()


func show_error_messages():
	var phrases: Array[String] = [
		"Lo siento Bitama, el número de copias que quieres realizar no son las que te pedi...",
		"Vuelve a intentarlo..."
	]
	await show_master_messages(phrases)
	add_attempt()
	executing_code = false
	set_code()
	loadHelp()


func sendCode(code):
	if executing_code:
		return
	executing_code = true
	var body = 	"function intro() {\n" + code + "\n}"
	ApiService.send_request(body, HTTPClient.METHOD_POST, "intro/for", "SEND_CODE")

func add_attempt():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, "score/attempts/bases_de_la_programacion/3", "ADD_ATTEMPT")
	
func complete_level():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, "score/complete/bases_de_la_programacion/3", "COMPLETE_LEVEL")


func next():
	LevelManager.load_scene(get_tree().current_scene.scene_file_path, nextLevel)
