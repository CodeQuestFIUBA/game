extends Node2D

@onready var player = $player
@onready var master = $master
@onready var enemy = $enemy
@onready var IDE = $CanvasLayer/IDE
@onready var sai_texture = "res://sprites/ninjas/blueNinja.png"
@onready var katana_texture = "res://sprites/ninjas/redNinja.png"
@onready var ninjaku_texture = "res://sprites/ninjas/grayNinja.png"
@onready var whip_texture = "res://sprites/ninjas/yellowNinja.png"
@onready var weapon_sai_texture = "res://sprites/weapons/Sai.png"
@onready var weapon_katana_texture = "res://sprites/weapons/Katana.png"
@onready var weapon_ninjaku_texture = "res://sprites/weapons/Ninjaku.png"
@onready var weapon_whip_texture = "res://sprites/weapons/Whip.png"


var player_origin: Array[Vector2] = [Vector2(57,216)]
var player_initial_move: Array[Vector2] = [ Vector2(57,130) ]
var grab_sai: Array[Vector2] = [ Vector2(57,64) ]
var grab_katana: Array[Vector2] = [ Vector2(57,90), Vector2(130,90), Vector2(130,64) ]
var grab_ninjaku: Array[Vector2] = [ Vector2(57,90), Vector2(208,90), Vector2(208,64) ]
var grap_whip: Array[Vector2] = [ Vector2(57,90), Vector2(270,90), Vector2(270,64) ]
var fight_area: Array[Vector2] = [ Vector2(57,90), Vector2(57,130) ]
var enemy_initial_move: Array[Vector2] = [ Vector2(361,55), Vector2(361,130), Vector2(264,130) ]
var enemy_final_move: Array[Vector2] = [ Vector2(361,130), Vector2(361,25) ]
var player_duel_position: Array[Vector2] = [ Vector2(153,130) ]
var enemy_duel_position: Array[Vector2] = [ Vector2(175,130) ]
var executing_code = false
var result = []
var orderResult: Array[String] = []
var weaponsByTable: Array[String] = ['sai', 'katana', 'ninjaku', 'whip']

func test_result():
	for weapon in orderResult:
		match weapon:
			'sai':
				result.push_back('ninjaku')
			'katana':
				result.push_back('whip')
			'ninjaku':
				result.push_back('katana')
			'whip':
				result.push_back('sai')

func _ready():
	orderResult = weaponsByTable.duplicate(true)
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
		"A continuación vendran maestros con alweapona de estas armas",
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
		var master_weapon = orderResult[i]
		var player_weapon = result[i]
		var correct_weapon = get_best_weapon(master_weapon)
		var valid_weapon = player_weapon == correct_weapon
		var phrases: Array[String] = []
		if i == 0:
			phrases = ['¡Empecemos el duelo!']
		else:
			phrases = ['¡Vamos con el siguiente duelo!']
		master.update_phrases(phrases, Vector2(56,155), true, {'auto_play_time': 1, 'close_by_signal': true})
		await DialogManager.signalCloseDialog
		await move_master_intial_position(master_weapon)
		await master_select_msg(master_weapon)
		await player_select_msg(player_weapon)
		await player_select_weapon(player_weapon)
		player.update_weapon_texture(get_weapon_texture(player_weapon))
		enemy.update_weapon_texture(get_weapon_texture(master_weapon))
		await startDuel(valid_weapon, correct_weapon)
		await move_all_initial_position()
		if !valid_weapon:
			executing_code = false
			return
	var phrases: Array[String] = ['¡Felicitaciones, lograste dominar todas las armas!', "Estas listo para seguir con los proximos desafios"]
	master.update_phrases(phrases, Vector2(56,155), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	player.update_destination(player_origin)
	await player.npcArrived


func master_select_msg(weapon: String):
	var phrases: Array[String] = []
	match weapon:
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


func player_select_msg(weapon: String):
	var phrases: Array[String] = []
	match weapon:
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


func move_master_intial_position(weapon: String):
	match weapon:
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


func move_all_initial_position():
	enemy.update_destination(enemy_final_move)
	player.update_destination(player_initial_move)
	await enemy.npcArrived and player.npcArrived
	

func player_select_weapon(weapon: String):
	match weapon:
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


func startDuel(valid_weapon: bool, correct_weapon: String):
	var phrases: Array[String] = ["¡Empecemos!"]
	master.update_phrases(phrases, Vector2(56,155), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	player.update_destination(player_duel_position)
	enemy.update_destination(enemy_duel_position)
	await player.npcArrived and enemy.npcArrived
	if valid_weapon:
		player.attack('right')
		await player.npcFinishAttack
		phrases = ['¡Muy bien hecho, elegiste el arma correcta!']
	else:
		enemy.attack('left')
		await enemy.npcFinishAttack
		phrases = ['Lo siento, el arma correcta era: ' + correct_weapon]
	master.update_phrases(phrases, Vector2(56,155), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog


func get_best_weapon(weapon: String):
	match weapon:
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
	executing_code = true
	#le paso las armas a la api
	test_result()
	process_result()


func process_response(resp):
	pass
