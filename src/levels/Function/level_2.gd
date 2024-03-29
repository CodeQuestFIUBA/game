extends Node2D

@onready var player = $player
@onready var master = $master
@onready var enemy = $enemy
@onready var IDE = $CanvasLayer/IDE
@onready var sai_texture = "res://sprites/ninjas/blueNinja.png"
@onready var katana_texture = "res://sprites/ninjas/redNinja.png"
@onready var ninjaku_texture = "res://sprites/ninjas/grayNinja.png"
@onready var whip_texture = "res://sprites/ninjas/yellowNinja.png"

var player_initial_move: Array[Vector2] = [ Vector2(57,132) ]
var grab_sai: Array[Vector2] = [ Vector2(57,64) ]
var grab_katana: Array[Vector2] = [ Vector2(57,90), Vector2(130,90), Vector2(130,64) ]
var grab_ninjaku: Array[Vector2] = [ Vector2(57,90), Vector2(208,90), Vector2(208,64) ]
var grap_whip: Array[Vector2] = [ Vector2(57,90), Vector2(270,90), Vector2(270,64) ]
var fight_area: Array[Vector2] = [ Vector2(57,90), Vector2(57,132) ]
var enemy_initial_move: Array[Vector2] = [ Vector2(361,55), Vector2(361,132), Vector2(264,132) ]
var enemy_final_move: Array[Vector2] = [ Vector2(361,132), Vector2(361,25) ]
var player_duel_position: Array[Vector2] = [ Vector2(150,132) ]
var enemy_duel_position: Array[Vector2] = [ Vector2(175,132) ]
var executing_code = false
var result = []
var orderResult: Array[String] = []
var gunsByTable: Array[String] = ['sai', 'katana', 'ninjaku', 'whip']

func test_result():
	for gun in orderResult:
		match gun:
			'sai':
				result.push_back('ninjaku')
			'katana':
				result.push_back('whip')
			'ninjaku':
				result.push_back('katana')
			'whip':
				result.push_back('sai')

func _ready():
	orderResult = gunsByTable.duplicate(true)
	randomize()
	orderResult.shuffle()
	ApiService.connect("signalApiResponse", process_response)
	IDE.connect("executeCodeSignal", sendCode)
	await process_intro()


func process_intro():
	player.update_destination(player_initial_move)
	await player.npcArrived
	var phrases: Array[String] = [
		"Bienvenido, es hora de aprender a utilizar las armas ninja", 
		"Debes saber que arma elegir segun el enemigo",
		"El Ninjaku tiene ventaja sobre el Sai",
		"El Sai sobre el Whip",
		"El Whip sobre la Katana",
		"Y la Katana sobre el Ninjaku",
		"A continuación vendran maestros con alguna de estas armas",
		"Y tendras que elegir el arma mas adecuada para vencerlo",
		"Escribe una función que recibe como parametro el arma del maestro",
		"Y retorne el arma que tiene ventaja sobre esa"
	]
	master.update_phrases(phrases, Vector2(56,155), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	var codeLines: Array[String] = ["function seleccionarArma(armaMaestro) {", "	//Ninjaku gana a Sai", "	//Sai gana a Whip", "	//Whip gana a Katana", "	//Katana gana a Ninjaku", "	", "}"]
	IDE.set_code(codeLines)

func process_result():
	for i in range(result.size()):
		var master_gun = orderResult[i]
		var player_gun = result[i]
		var correct_gun = get_best_gun(master_gun)
		var valid_gun = player_gun == correct_gun
		var phrases: Array[String] = []
		if i == 0:
			phrases = ['¡Empecemos el duelo!']
		else:
			phrases = ['¡Vamos con el siguiente duelo!']
		master.update_phrases(phrases, Vector2(56,155), true, {'auto_play_time': 1, 'close_by_signal': true})
		await DialogManager.signalCloseDialog
		await move_master_intial_position(master_gun)
		await master_select_msg(master_gun)
		await player_select_msg(player_gun)
		await player_select_gun(player_gun)
		await startDuel(valid_gun, correct_gun)
		await move_all_initial_position()
		if !valid_gun:
			return


func master_select_msg(gun: String):
	var phrases: Array[String] = []
	match gun:
		'sai':
			phrases = ['El maestro eligio el Sai']
		'katana':
			phrases = ['El maestro eligio la Katana']
		'ninjaku':
			phrases = ['El maestro eligio el Ninjaku']
		'whip':
			phrases = ['El maestro eligio el Whip']
	phrases.push_back("¿Qué arma elegiste para vencerlo?")
	master.update_phrases(phrases, Vector2(56,155), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog


func player_select_msg(gun: String):
	var phrases: Array[String] = []
	match gun:
		'sai':
			phrases = ['Elegi el Sai']
		'katana':
			phrases = ['Elegi la Katana']
		'ninjaku':
			phrases = ['Elegi el Ninjaku']
		'whip':
			phrases = ['Elegi el Whip']
	player.update_phrases(phrases, Vector2(74,110), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog


func move_master_intial_position(gun: String):
	match gun:
		'sai':
			enemy.update_texture(sai_texture)
		'katana':
			enemy.update_texture(katana_texture)
		'ninjaku':
			enemy.update_texture(ninjaku_texture)
		'whip':
			enemy.update_texture(whip_texture)
	enemy.update_destination(enemy_initial_move)
	await enemy.npcArrived


func move_all_initial_position():
	enemy.update_destination(enemy_final_move)
	player.update_destination(player_initial_move)
	await enemy.npcArrived and player.npcArrived
	

func player_select_gun(gun: String):
	match gun:
		'sai':
			player.update_destination(grab_sai)
		'katana':
			player.update_destination(grab_katana)
		'ninjaku':
			player.update_destination(grab_ninjaku)
		'whip':
			player.update_destination(grap_whip)
	await player.npcArrived
	await get_tree().create_timer(0.4).timeout
	player.update_destination(fight_area)
	await player.npcArrived


func startDuel(valid_gun: bool, correct_gun: String):
	var phrases: Array[String] = ["¡Empecemos!"]
	master.update_phrases(phrases, Vector2(56,155), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	player.update_destination(player_duel_position)
	enemy.update_destination(enemy_duel_position)
	await player.npcArrived and enemy.npcArrived
	await get_tree().create_timer(0.4).timeout
	if valid_gun:
		phrases = ['¡Muy bien hecho, elegiste el arma correcta!']
	else:
		phrases = ['Lo siento, el arma correcta era: ' + correct_gun]
	master.update_phrases(phrases, Vector2(56,155), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog


func get_best_gun(gun: String):
	match gun:
		'sai':
			return 'ninjaku'
		'katana':
			return 'whip'
		'ninjaku':
			return 'katana'
		'whip':
			return 'sai'


func sendCode(code):
	if executing_code:
		return
	#le paso las armas a la api
	test_result()
	process_result()


func process_response(resp):
	pass
