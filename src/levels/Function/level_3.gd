extends Node2D

@onready var IDE = $CanvasLayer/IDE
@onready var player = $player
@onready var copy_player_1 = $player1
@onready var copy_player_2 = $player2
@onready var master = $master
@onready var master2 = $master2
@onready var enemy_1 = $enemy1
@onready var enemy_2 = $enemy2
@onready var enemy_3 = $enemy3
@onready var weapon_sai_texture = "res://sprites/weapons/Sai.png"
@onready var weapon_katana_texture = "res://sprites/weapons/Katana.png"
@onready var weapon_ninjaku_texture = "res://sprites/weapons/Ninjaku.png"
@onready var weapon_whip_texture = "res://sprites/weapons/Whip.png"

var player_initial_position: Array[Vector2] = [Vector2(101,119)]
var enemy1_initial_position: Array[Vector2] = [Vector2(280,86), Vector2(264,86)]
var enemy2_initial_position: Array[Vector2] = [Vector2(328,119), Vector2(264,119)]
var enemy3_initial_position: Array[Vector2] = [Vector2(375,154), Vector2(264,154)]
var enemy1_final_position: Array[Vector2] = [Vector2(195,86)]
var enemy2_final_position: Array[Vector2] = [Vector2(195,119)]
var enemy3_final_position: Array[Vector2] = [Vector2(195,154)]
var player1_final_position: Array[Vector2] = [Vector2(170,86)]
var player_final_position: Array[Vector2] = [Vector2(170,119)]
var player2_final_position: Array[Vector2] = [Vector2(170,154)]
var player_end_position: Array[Vector2] = [Vector2(181,216)]
var executing_code = false
var weapons: Array[String] = ['sai', 'katana', 'ninjaku', 'whip']

var master_msg_position = Vector2(90,76)

func get_valid_weapon(weapon: String):
	match weapon:
		'sai':
			return 'ninjaku'
		'katana':
			return 'whip'
		'ninjaku':
			return 'katana'
		'whip':
			return 'sai'


# Called when the node enters the scene tree for the first time.
func _ready():
	ApiService.connect("signalApiResponse", process_response)
	IDE.connect("executeCodeSignal", sendCode)
	process_intro()



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
	show_message(phrases)


func show_message(phrases):
	master.update_phrases(phrases, master_msg_position, true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	executing_code = false
	loadHelp()


func loadHelp():
	var phrases: Array[String] = [
		"Recuerda seleccionar el arma adecuada...",
		"Recuerda no hacer copias de más o te agotaras...",
		"Recuerda que si son X enemigos debes hacer X copias..."
	]
	master.update_phrases(phrases, master_msg_position, false, {'auto_play_time': 1, 'close_by_signal': true})


func process_intro():
	player.update_destination(player_initial_position)
	await player.npcArrived
	var phrases: Array[String] = [
		"Bienvenida Bitama, estas listo para el ultimo desafio",
		"Pero antes, vamos a volver a practicar la tecnica de clonación"
	]
	master.update_phrases(phrases, Vector2(90,76), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	master2.visible = true
	phrases = [
		"Con esta tecnica podras generar copias de ti mismo y enfrentar a más rivales",
		"Pero no debes debes hacer clones de mas",
		"Ya que te agotara y te afectara para futuras batallas"
	]
	master.update_phrases(phrases, master_msg_position, true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	master2.visible = false
	phrases = [
		"A continuación deberás enfrentar a una cantidad incierta de rivales, que devastaron estas tierras",
		"Ellos utilizaran el mismo tipo de arma",
		"Tendrás que elegir el arma que sea más poderosa que la de tu rival",
		"Y utilizar la técnica clon de sombra para igualar la cantidad de rivales y vencerlos",
		"Escribe un función que recibe como parámetro la cantidad de enemigos y el arma de los enemigos",
		"Y retorne un objeto con los campos:",
		"arma: con el arma a utilizar",
		"total: con la cantidad de copias a realizar"
	]
	master.update_phrases(phrases, master_msg_position, true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	var codeLines: Array[String] = ["function pelear(cantidadEnemigos, armaEnemigo) {", "	//Ninjaku gana a Sai", "	//Sai gana a Whip", "	//Whip gana a Katana", "	//Katana gana a Ninjaku", "	", "	return {", "		arma: ''", "		total: 0", "	}", "}"]
	IDE.set_code(codeLines)
	loadHelp()

func get_weapon_texture(weapon: String):
	match weapon:
		'sai':
			return weapon_sai_texture
		'katana':
			return weapon_katana_texture
		'ninjaku':
			return weapon_ninjaku_texture
		'whip':
			return weapon_whip_texture

func move_enemies_initial_position(round):
	if round["total"] == 2:
		enemy_1.update_destination(enemy1_initial_position)
		enemy_2.update_destination(enemy2_initial_position)
		await enemy_1.npcArrived 
		await enemy_2.npcArrived
		enemy_1.update_weapon_texture(get_weapon_texture(round['arma']))
		enemy_2.update_weapon_texture(get_weapon_texture(round['arma']))
		enemy_1.attack('left')
		enemy_2.attack('left')
		await enemy_1.npcFinishAttack and await enemy_2.npcFinishAttack
	else:
		enemy_1.update_destination(enemy1_initial_position)
		enemy_2.update_destination(enemy2_initial_position)
		enemy_3.update_destination(enemy3_initial_position)
		await enemy_1.npcArrived 
		await enemy_2.npcArrived 
		await enemy_3.npcArrived
		enemy_1.update_weapon_texture(get_weapon_texture(round['arma']))
		enemy_2.update_weapon_texture(get_weapon_texture(round['arma']))
		enemy_3.update_weapon_texture(get_weapon_texture(round['arma']))
		enemy_1.attack('left')
		enemy_2.attack('left')
		enemy_3.attack('left')
		await enemy_1.npcFinishAttack and await enemy_2.npcFinishAttack and await enemy_3.npcFinishAttack


func load_player_initial_position(round):
	if round["total"] == 2:
		copy_player_1.visible = true
	else:
		copy_player_1.visible = true
		copy_player_2.visible = true
	copy_player_1.update_weapon_texture(get_weapon_texture(round['arma']))
	copy_player_2.update_weapon_texture(get_weapon_texture(round['arma']))
	player.update_weapon_texture(get_weapon_texture(round['arma']))

func battle(total: int, valid_weapon: bool, valid_total: bool):
	if total == 2:
		enemy_1.update_destination(enemy1_final_position)
		enemy_2.update_destination(enemy2_final_position)
		copy_player_1.update_destination(player1_final_position)
		player.update_destination(player_final_position)
		await enemy_1.npcArrived and await enemy_2.npcArrived and await copy_player_1.npcArrived and await player.npcArrived
	else:
		enemy_1.update_destination(enemy1_final_position)
		enemy_2.update_destination(enemy2_final_position)
		enemy_3.update_destination(enemy3_final_position)
		copy_player_1.update_destination(player1_final_position)
		player.update_destination(player_final_position)
		copy_player_2.update_destination(player2_final_position)
		await enemy_1.npcArrived and await enemy_2.npcArrived and await enemy_3.npcArrived and await copy_player_1.npcArrived and await player.npcArrived and await copy_player_2.npcArrived
	if valid_weapon:
		player.attack('right')
		copy_player_1.attack('right')
		copy_player_2.attack('right')
		await player.npcFinishAttack and await copy_player_1.npcFinishAttack and await copy_player_2.npcFinishAttack
		enemy_1.dead()
		enemy_2.dead()
		enemy_3.dead()
	else:
		enemy_1.attack('left')
		enemy_2.attack('left')
		enemy_3.attack('left')
		await enemy_1.npcFinishAttack and await enemy_2.npcFinishAttack and await enemy_3.npcFinishAttack
		player.dead()
		copy_player_1.visible = false
		copy_player_2.visible = false
	await get_tree().create_timer(1).timeout
	copy_player_1.visible = false
	copy_player_2.visible = false
	enemy_1.visible = false
	enemy_2.visible = false
	enemy_3.visible = false
	var phrases: Array[String] = []
	if valid_total && valid_weapon:
		phrases= [
			"¡Muy bien, lograste vencer a nuestros enemigos!",
			"Ahora estas listo para enfrentar al jefe Spaghetti Shadowblade"
		]
		complete_level()
	elif !valid_weapon:
		phrases= [
			"Lo siento, el arma no fue la correcta",
			"Vamos a intentarlo nuevamente"
		]
		add_attempt()
	else:
		phrases= [
			"Lo siento, la cantidad de clones fueron incorrectos",
			"Vamos a intentarlo nuevamente"
		]
		add_attempt()
	master.update_phrases(phrases, Vector2(90,76), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog


func process_result(data):
	var enemy_result = data['enemy_result']
	var result = data["user_result"]
	await move_enemies_initial_position(enemy_result)
	await load_player_initial_position(result)
	var valid_weapon = get_valid_weapon(enemy_result['arma']) == result['arma']
	var valid_total = result['total'] == enemy_result['total']
	await battle(enemy_result['total'], valid_weapon, valid_total)
	copy_player_1.position = Vector2(101,86)
	copy_player_2.position = Vector2(101,154)
	enemy_1.position = Vector2(280,8)
	enemy_2.position = Vector2(328,8)
	enemy_3.position = Vector2(375,8)
	enemy_1.visible = true
	enemy_2.visible = true
	enemy_3.visible = true
	if valid_total && valid_weapon:
		player.update_destination(player_end_position)
		await player.npcArrived
	else:
		player.position = Vector2(101,119)
		player.update_destination(player_initial_position)
		await player.npcArrived
		executing_code = false

func sendCode(code):
	if executing_code:
		return
	executing_code = true
	ApiService.send_request(code, HTTPClient.METHOD_POST, "functions/object", "SEND_CODE")

func add_attempt():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, "score/attempts/funciones_y_operadores/2", "ADD_ATTEMPT")
	
func complete_level():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, "score/complete/funciones_y_operadores/2", "COMPLETE_LEVEL")
