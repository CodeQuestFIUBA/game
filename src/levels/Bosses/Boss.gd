extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
# Signal to indicate an answer has been selected
signal answer_selected(correct)

# --- VARIABLES OVERRIDED BY THE PARENT ---
var questions = null
var codeLines: Array[String]
var post_quiz_phrases: Array[String]
var intro_phrases: Array[String]
var enemy_msg_position = Vector2(200,130)
var help_phrases: Array[String]

var check_if_result_is_correct

var request_path = null
var add_attempt_path = null
var add_complete_path = null
# ----------------------------------------------

var executing_code = false

@onready var player = $Player
@onready var boss = $Boss

@onready var IDE = $CanvasLayer/IDE

@onready var quest = $Control
@onready var question = $Control/ScrollContainer/VBoxContainer/Question
var current_question = 0

@onready var lifeBars = $LifeBars
@onready var lifeBarPlayer = $LifeBars/PlayerLifeBar
@onready var lifeBarBoss = $LifeBars/BossLifeBar

@onready var buttonA = $Control/ScrollContainer/VBoxContainer/Options/OptionA/Button
@onready var buttonB = $Control/ScrollContainer/VBoxContainer/Options/OptionB/Button
@onready var buttonC = $Control/ScrollContainer/VBoxContainer/Options/OptionC/Button
@onready var buttonD = $Control/ScrollContainer/VBoxContainer/Options/OptionD/Button
@onready var buttonContinue = $Control/ScrollContainer/VBoxContainer/Options/Continue/Button

@onready var labelA = $Control/ScrollContainer/VBoxContainer/Options/OptionA/RichTextLabel
@onready var labelB = $Control/ScrollContainer/VBoxContainer/Options/OptionB/RichTextLabel
@onready var labelC = $Control/ScrollContainer/VBoxContainer/Options/OptionC/RichTextLabel
@onready var labelD = $Control/ScrollContainer/VBoxContainer/Options/OptionD/RichTextLabel

@onready var NinjaPosition_Inicio_1 = $"NinjaPosition-1"
@onready var NinjaPosition_Inicio_2 = $"NinjaPosition-2"

@onready var NinjaAttackPosition = $"NinjaAttackPosition"
@onready var BossPosition = $"BossPosition"
@onready var BossAttackPosition = $"BossAttackPosition"

var enemy_defeated: Array[String] = [
	"Oh NO!!! La solución es correcta",
	"Me has derrotado"
];

func _ready():
	
	ApiService.login("ezequiel@gmail.com", "123asd", "LOGIN");
	if ApiService:
		ApiService.connect("signalApiResponse", process_response)
	IDE.connect("executeCodeSignal", sendCode)

	var playerSteps: Array[Vector2] = [ 
		NinjaPosition_Inicio_1.global_position,
		NinjaPosition_Inicio_2.global_position
	]
	var phrases: Array[String] = []
	
	player.update_destination(playerSteps)
	await player.npcArrived
	
	lifeBars.visible = true

	boss.update_phrases(intro_phrases, enemy_msg_position, true, {'auto_play_time': 3, 'close_by_signal': true})
	
	await DialogManager.signalCloseDialog
	
	# Connect buttons to the on_answer_selected function using lambdas
	buttonA.connect("pressed", _on_AnswerButton_pressed.bind(0))
	buttonB.connect("pressed", _on_AnswerButton_pressed.bind(1))
	buttonC.connect("pressed", _on_AnswerButton_pressed.bind(2))
	buttonD.connect("pressed", _on_AnswerButton_pressed.bind(3))

	
	buttonContinue.visible = false
	quest.visible = true
	
	show_question()

func show_question():
	var question_data = questions[current_question]
	
	question.bbcode_text=question_data["question"]
	
	labelA.bbcode_text=question_data["answers"][0]
	labelB.bbcode_text=question_data["answers"][1]
	labelC.bbcode_text=question_data["answers"][2]
	labelD.bbcode_text=question_data["answers"][3]
	

func player_loss_life():
	print("Incorrect!")
	var npcSteps: Array[Vector2] = []
	npcSteps = [
		BossAttackPosition.global_position,
		BossAttackPosition.global_position
	]
	boss.update_destination(npcSteps)
	await boss.npcArrived
	
	lifeBarPlayer.life -= 1
	
	boss.attack("left")
	await boss.npcFinishAttack
	
	npcSteps = [
		BossPosition.global_position,
		BossPosition.global_position
	]
	boss.update_destination(npcSteps)
	await boss.npcArrived

func boss_loss_life():
	print("Correct!")
	var npcSteps: Array[Vector2] = []
	npcSteps = [
		NinjaAttackPosition.global_position,
		NinjaAttackPosition.global_position
	]
	player.update_destination(npcSteps)
	
	await player.npcArrived
	
	lifeBarBoss.life -= 1
	
	player.attack("right")
	await player.npcFinishAttack
	
	npcSteps = [
		NinjaPosition_Inicio_2.global_position,
		NinjaPosition_Inicio_2.global_position
	]
	player.update_destination(npcSteps)

	await player.npcArrived

func _on_AnswerButton_pressed(answer_index):
	var npcSteps: Array[Vector2] = []
	
	var correct_answer = questions[current_question]["correct"]
	
	if answer_index == 0 && answer_index != correct_answer:
		labelA.bbcode_text="[color=#FF0000]" + questions[current_question]["answers"][0] + "[/color]"
	elif answer_index == 1 && answer_index != correct_answer:
		labelB.bbcode_text="[color=#FF0000]" + questions[current_question]["answers"][1] + "[/color]"
	elif answer_index == 2 && answer_index != correct_answer:
		labelC.bbcode_text="[color=#FF0000]" + questions[current_question]["answers"][2] + "[/color]"
	elif answer_index == 3 && answer_index != correct_answer:
		labelD.bbcode_text="[color=#FF0000]" + questions[current_question]["answers"][3] + "[/color]"
	
	if correct_answer == 0:
		labelA.bbcode_text="[color=#008000]" + questions[current_question]["answers"][0] + "[/color]"
	elif correct_answer == 1:
		labelB.bbcode_text="[color=#008000]" + questions[current_question]["answers"][1] + "[/color]"
	elif correct_answer == 2:
		labelC.bbcode_text="[color=#008000]" + questions[current_question]["answers"][2] + "[/color]"
	elif correct_answer == 3:
		labelD.bbcode_text="[color=#008000]" + questions[current_question]["answers"][3] + "[/color]"
	
	buttonContinue.visible = true
	
	await buttonContinue.pressed
	quest.visible = false
	
	if answer_index == correct_answer:
		await boss_loss_life()
		
	else:
		await player_loss_life()
		
	current_question += 1
	
	print(lifeBarPlayer.life)
	print(lifeBarBoss.life)
	

	if current_question < questions.size():
		show_question()
	else:
		print("Quiz finished!")
		# Optionally, restart the quiz or end the game
	
	
	if lifeBarBoss.life <= 1:
		run_last_phase()
		
	elif lifeBarPlayer.life <= 1:
		# continuar etapa
		pass
	else:
		quest.visible = true
		buttonContinue.visible = false
		
func run_last_phase():
	print("Start Last Phase")
	
	boss.update_phrases(post_quiz_phrases, enemy_msg_position, true, {'auto_play_time': 3, 'close_by_signal': true})
	
	await DialogManager.signalCloseDialog
	
	IDE.visible = true
	IDE.set_ide_visible(true)
	
	IDE.set_code(codeLines)

func sendCode(code):
	if executing_code:
		return
	print(code)
	executing_code = true
	#var body = "function intro() {\n" + code + "\n}"
	ApiService.send_request(code, HTTPClient.METHOD_POST, request_path, "SEND_CODE")

func add_attempt():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, add_attempt_path, "ADD_ATTEMPT")
	
func complete_level():
	ApiService.send_request("{}", HTTPClient.METHOD_PUT, add_complete_path, "COMPLETE_LEVEL")


func process_response(res, extraArg):
	match extraArg:
		"LOGIN": pass
		"COMPLETE_LEVEL": pass
		"ADD_ATTEMPT": pass
		"SEND_CODE": 
	#		if !res || res["code"] != 200:
	#			show_error_response(res["message"])
	#			return;
	#		process_result(res["data"]["result"])
	
			boss.update_phrases(enemy_defeated, enemy_msg_position, true, {'auto_play_time': 1, 'close_by_signal': true})
			
			await DialogManager.signalCloseDialog
			
			var npcSteps: Array[Vector2] = []
			npcSteps = [
				NinjaAttackPosition.global_position,
				NinjaAttackPosition.global_position
			]
			player.update_destination(npcSteps)
			
			await player.npcArrived
			
			lifeBarBoss.life -= 1
			player.attack("right")

			await boss.dead()

			await player.npcFinishAttack
			
			var victory_phrases: Array[String] = [
				"La victoria es nuestra",
			];

			player.update_phrases(victory_phrases, Vector2(140,130), true, {'auto_play_time': 1, 'close_by_signal': true})
			
			await DialogManager.signalCloseDialog
						
			await get_tree().create_timer(2).timeout
			
			
			var home_loby = "res://main.tscn"
			LevelManager.load_scene(get_tree().current_scene.scene_file_path, home_loby)

func process_result(result):
	var is_correct: bool = check_if_result_is_correct.call()

	if !is_correct:
		print("Es erróneo")
		var phrases: Array[String] = [
			"Tu código puede ser ejecutado pero no resuelve el problema"
		]
		await show_message(phrases)
		await player_loss_life()
	else:
		print("Es correcto")
		var phrases: Array[String] = [
			"Nooooo me has derrotado!!!"
		]
		await show_message(phrases)
		await boss_loss_life()

	executing_code = false

func show_error_response(error: String):
	var phrases: Array[String] = [
		"Lo siento Bitama, pero no se pudo \nejecutar tu código",
		"Tu código tiene el siguiente error",
		error,
		"Mientras sigas fallando seguiras \nrecibiendo mis ataques"
	]
	
	await show_message(phrases)
	
	await player_loss_life()

func show_message(phrases):
	boss.update_phrases(phrases, enemy_msg_position, true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog
	executing_code = false
	loadHelp()
	
func loadHelp():
	boss.update_phrases(help_phrases, enemy_msg_position, false, {'auto_play_time': 1, 'close_by_signal': true})
