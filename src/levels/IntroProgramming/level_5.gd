extends Node2D


@onready var player = $Player
@onready var master = $Master
@onready var IDE = $CanvasLayer/IDE
@onready var npc = $Npc
@onready var guardian_1 = $Guardian_1
@onready var guardian_2 = $Guardian_2
var executing_code = false

var master_msg_position: Vector2 = Vector2(88, 160)
var player_msg_position: Vector2 = Vector2(120, 160)
var npc_msg_position: Vector2 = Vector2(140, 160)

var npc_start_steps: Array[Vector2] = [ Vector2(168,56)]
var npc_initial_steps: Array[Vector2] = [ Vector2(168,136)]
var npc_final_steps: Array[Vector2] = [ Vector2(168,240)]
var guardian_steps: Array[Vector2] = [ Vector2(168,80), Vector2(168,240)]
var player_final_steps: Array[Vector2] = [ Vector2(168,136), Vector2(168,240)]

var npc_initial_position: Vector2 = Vector2(168,32)

var message_first_clan = "Fuerza al clan 1";
var message_second_clan = "Fuerza al clan 2";

var message_first_clan_master = "Este es del clan 1";
var message_second_clan_master = "Este es del clan 2";

var message_npc = "Presenta tus respetos con el clan mas fuerte, o muere!!";


# Called when the node enters the scene tree for the first time.
func _ready():
	IDE.connect("executeCodeSignal", sendCode)
	var phrases: Array[String] = [
		"Hola discipulo",
		"Es hora de aprender el ciclo while",
		"Reunion de dos clanes...",
		"Saludar uno hola clan clan_1...",
		"Saludar uno hola clan clan_2...",
		"Terminar mensaje listo..."
	]
	await show_messages(phrases, master_msg_position)
	set_code()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_code():
	var codeLines: Array[String] = [
		"//Funcion que retorna el saludo a realizar",
		"//preguntarSaludo()",
		"//Funcion que emite el saludo correspondiente segun el mensaje",
		"//saludar(mensaje)",
		"const SALUDO_CLAN_1 = 'CLAN_1';",
		"const SALUDO_CLAN_2 = 'CLAN_2';",
		"const SALIR = 'SALIR';",
		"",
		"",
		"var saludo = preguntarSaludo()",
		"",
		"//Dentro del while se debe llamar a saludar y volver a obtener a preguntar al maestro",
		"while (saludo !== SALIR) {",
		"	//llamar a saludar(mensaje)",
		"	saludo = preguntarSaludo();",
		"}"
	]
	IDE.set_code(codeLines)

func show_messages(phrases: Array[String], position: Vector2):
	master.update_phrases(phrases, position, true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog



func process_result(result):
	var masterPhrases: Array[String] = []
	var playerPhrases: Array[String] = []
	var npcPhrases: Array[String] = [message_npc]
	var correct_message = true
	for i in range(result.size()):
		if result[i]["clan"] == "CLAN_1":
			masterPhrases = [message_first_clan_master]
		else:
			masterPhrases = [message_second_clan_master]
		if result[i]["message"] == "CLAN_1":
			playerPhrases = [message_first_clan]
		else:
			playerPhrases = [message_second_clan]
		npc.update_destination(npc_start_steps)
		await npc.npcArrived
		await show_messages(masterPhrases, master_msg_position)
		npc.update_destination(npc_initial_steps)
		await npc.npcArrived
		await show_messages(npcPhrases, npc_msg_position)
		await show_messages(playerPhrases, player_msg_position)
		npc.update_destination(npc_final_steps)
		await npc.npcArrived
		npc.position = npc_initial_position
	npc.queue_free()
	guardian_1.update_destination(guardian_steps)
	await guardian_1.npcArrived
	guardian_1.queue_free()
	guardian_2.update_destination(guardian_steps)
	await guardian_2.npcArrived
	guardian_2.queue_free()
	masterPhrases = [
		"Bien hecho discipulo, terminaste el desafio",
		"Ahora puedes seguir con el siguiente"
	]
	await show_messages(masterPhrases, master_msg_position)
	player.update_destination(player_final_steps)
	await player.npcArrived

func sendCode(code):
	if executing_code:
		return
	executing_code = true
	var result = [
		{
			"clan": "CLAN_1",
			"message": "CLAN_1",
		},
		{
			"clan": "CLAN_2",
			"message": "CLAN_2",
		},
		{
			"clan": "CLAN_1",
			"message": "CLAN_1",
		},
		{
			"clan": "CLAN_2",
			"message": "CLAN_2",
		},
		{
			"clan": "CLAN_2",
			"message": "CLAN_2",
		}
	]
	#le paso las armas a la api
	process_result(result)
