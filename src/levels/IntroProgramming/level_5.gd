extends Node2D


@onready var player = $Player
@onready var master = $Master
@onready var JR = $JR
@onready var IDE = $CanvasLayer/IDE
@onready var npc = $Npc
@onready var slave = $Slave
var executing_code = false

var msg_position: Vector2 = Vector2(88, 160)
var player_msg_position: Vector2 = Vector2(120, 160)
var npc_msg_position: Vector2 = Vector2(140, 160)

var action_position: Array[Vector2] = [Vector2(160, 112)]
var origin_position: Array[Vector2] = [Vector2(160, 96)]
var pos_1: Vector2  = Vector2(248, 80)
var pos_2: Vector2  = Vector2(72, 56)
var pos_3: Vector2  = Vector2(24, 16)
var steps_1: Array[Vector2] = [Vector2(248, 128), Vector2(160, 128) ]
var steps_2: Array[Vector2] = [Vector2(72, 128), Vector2(160, 128) ]
var steps_3: Array[Vector2] = [Vector2(24, 112), Vector2(72, 112), Vector2(72, 128), Vector2(160, 128) ]
var free_steps: Array[Vector2] = [Vector2(-16, 128)]
var initial_npc_pos: Vector2 = Vector2(40, -16)

var jr_steps: Array[Vector2] = [Vector2(104, 200), Vector2(168, 200), Vector2(168, 128)]
var jr_final_steps: Array[Vector2] = [Vector2(456, 128)]

var player_final_steps: Array[Vector2] = [Vector2(160, 128), Vector2(416, 128)]

var message_first_clan = "Fuerza al clan 1";
var message_second_clan = "Fuerza al clan 2";

var message_first_clan_master = "Este es del clan 1";
var message_second_clan_master = "Este es del clan 2";

var message_npc = "Presenta tus respetos con el clan mas fuerte, o muere!!";


# Called when the node enters the scene tree for the first time.
func _ready():
	if ApiService:
		ApiService.connect("signalApiResponse", process_response)
	#ApiService.login("mafvidal35@gmail.com", "Asd123456+", "LOGIN");
	IDE.connect("executeCodeSignal", sendCode)
	var phrases: Array[String] = [
		"Hola Bitama, por fin encontramos a JR…",
		"Según nuestros ninjas aliados se encuentra en una de estas casas abandonadas…",
		"Pero también está lleno de sus guardias…",
		"Y lamentablemente también tienen aldeanos esclavizados…",
		"Deberás atacar a los guardias, pero liberar a los aldeanos…",
		"Deberás seguir atacando mientras queden guardias…",
		"Cuando ya no queden guardias, JR saldrá y podremos acabar con su tiranía…"
	]
	await show_messages(phrases)
	set_code()


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
	master.update_phrases(phrases, msg_position, true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	executing_code = false
	loadHelp()


func loadHelp():
	var phrases: Array[String] = [
		"Recueda utilizar la función quedanGuardias() como condición de corte en el ciclo while",
		"Recueda utilizar la función esGuardia() que te retorna true en caso de que lo sea",
		"Recueda utilizar la función atacar() para atacar al guardia si lo es",
		"Recueda utilizar la función liberar() para liberar a los esclavos"
		
	]
	master.update_phrases(phrases, msg_position, false, {'auto_play_time': 1, 'close_by_signal': true})


func set_code():
	var codeLines: Array[String] = [
		"//quedanGuardias()",
		"//esGuardia()",
		"//atacar()",
		"//liberar()"
	]
	IDE.set_code(codeLines)


func show_messages(phrases: Array[String]):
	master.update_phrases(phrases, msg_position, true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog


func get_pos(i):
	match i:
		1: return pos_1
		2: return pos_2
		_: return pos_3


func get_steps(i):
	match i:
		1: return steps_1
		2: return steps_2
		_: return steps_3

func animateSlave(initial_pos, inital_steps, correct):
	slave.position = initial_pos
	slave.update_destination(inital_steps)
	await slave.npcArrived
	if correct:
		player.update_destination(action_position)
		await player.npcArrived
		var phrases: Array[String] = [
			"Eres libre aldeano…",
			"Gracias Bitama, ¡¡vence a JR por favor!!",
		]
		await show_messages(phrases)
		player.update_destination(origin_position)
		slave.update_destination(free_steps)
		await slave.npcArrived
	else:
		player.update_destination(action_position)
		await player.npcArrived
		var phrases: Array[String] = [
			"Fin a la tirania de JR…",
			"No Bitama, es un aldeano..."
		]
		await show_messages(phrases)
		player.update_destination(origin_position)
		slave.update_destination(free_steps)
		await slave.npcArrived
		
func animateGuardian(initial_pos, inital_steps, correct):
	npc.position = initial_pos
	npc.update_destination(inital_steps)
	await npc.npcArrived
	if correct:
		player.update_destination(action_position)
		await player.npcArrived
		var phrases: Array[String] = [
			"Fin a la tirania de JR…",
		]
		await show_messages(phrases)
		player.attack("down")
		npc.dead()
		await player.npcFinishAttack
		player.update_destination(origin_position)
		npc.position = initial_npc_pos
	else:
		var phrases: Array[String] = [
			"Eres libre aldeano…",
			"Hmm ¿Qué?...",
			"Shhh Bitama, es un guardia…",
		]
		await show_messages(phrases)
		var return_stepes: Array[Vector2] = inital_steps.duplicate()
		return_stepes.reverse()
		return_stepes.append(initial_pos)
		npc.update_destination(return_stepes)
		await npc.npcArrived
		npc.position = initial_npc_pos


func show_error_message():
	var phrases: Array[String] = [
		"Lo siento Bitama, pero tu algoritmo fue incorrecto…",
		"Volvamos a intentarlo...",
	]
	add_attempt()
	await show_messages(phrases)
	executing_code = false
	loadHelp()
	set_code()


func process_result(result):
	var masterPhrases: Array[String] = []
	var playerPhrases: Array[String] = []
	var npcPhrases: Array[String] = [message_npc]
	var correct_level = true
	if len(result["colaDelUsuario"]) != len(result["cola"]):
		await show_error_message()
		return
	for i in range(len(result["colaDelUsuario"])):
		var correct = result["colaDelUsuario"][i] == result["cola"][i]
		randomize()
		var random_number = randi() % 3 + 1
		var initial_pos: Vector2 = get_pos(random_number)
		var inital_steps: Array[Vector2] = get_steps(random_number)
		if result["cola"][i] == "GUARDIA":
			await animateGuardian(initial_pos, inital_steps, correct)
		else:
			await animateSlave(initial_pos, inital_steps, correct)
		if !correct:
			await show_error_message()
			correct_level = false
			break
	if correct_level:
		complete_level()
		JR.update_destination(jr_steps)
		await JR.npcArrived
		var phrases: Array[String] = [
			"Oooh no, mis guardias donde estan…",
			"¡¡Bitama!!, y sin ayuda de mis guardias no podre hacer nada...",
			"¡¡¡Ayudaaaaa!!!"
		]
		add_attempt()
		await show_messages(phrases)
		JR.update_destination(jr_final_steps)
		await JR.npcArrived
		phrases = [
			"¡¡Vamos Bitama!!…",
			"Es hora de derrotar a JR..."
		]
		await show_messages(phrases)
		player.update_destination(player_final_steps)
		await player.npcArrived

func sendCode(code):
	if executing_code:
		return
	executing_code = true
	var body = 	"function intro() {\n" + code + "\n}"
	ApiService.send_request(body, HTTPClient.METHOD_POST, "intro/while", "SEND_CODE")

func add_attempt():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, "score/attempts/bases_de_la_programacion/4", "ADD_ATTEMPT")
	
func complete_level():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, "score/complete/bases_de_la_programacion/4", "COMPLETE_LEVEL")
