extends Node2D

var move_speed = 50
var destination_position

var nextLevel = "res://levels/Matrix/level_1/level.tscn";

@onready var player = $Player
@onready var master = $Master

@onready var ide = $IDE

@onready var ideInstructions = $IDE/Instructions/MarginContainer/Instructions

#@onready var ExecutionResult = $"ExecutionResult"

@onready var BoxPosition_Inicio_1 = $"Vector/BoxPosition-Inicio-1"
@onready var BoxPosition_Inicio_2 = $"Vector/BoxPosition-Inicio-2"
@onready var BoxPosition_Final_1 = $"Vector/BoxPosition-Final-1"
@onready var BoxPosition_Final_2 = $"Vector/BoxPosition-Final-2"

@onready var BoxPosition_1 = $"Vector/BoxPosition-1"
@onready var BoxPosition_2 = $"Vector/BoxPosition-2"
@onready var BoxPosition_3 = $"Vector/BoxPosition-3"
@onready var BoxPosition_4 = $"Vector/BoxPosition-4"
@onready var BoxPosition_5 = $"Vector/BoxPosition-5"

@onready var Box_1 = $"Vector/BoxWithNumber-1"
@onready var Box_2 = $"Vector/BoxWithNumber-2"
@onready var Box_3 = $"Vector/BoxWithNumber-3"
@onready var Box_4 = $"Vector/BoxWithNumber-4"
@onready var Box_5 = $"Vector/BoxWithNumber-5"

var response



var current_box
var current_box_path_position
var number_current_box = 1

var isReturningFromBox = true

var waiting_to_begin = true

var vector_sorted_message: Array[String] = [
	"¡Excelente! La clave es correcta!!!.",
];

var box_states : Array = [
	[1,2,5,4,3],
[1, 2, 4, 4, 3],
[1, 2, 4, 5, 3],
[1, 2, 4, 3, 3],
[1, 2, 4, 3, 5],
[1, 2, 3, 3, 5],
[1, 2, 3, 4, 5],
[1, 2, 3, 4, 5]]

var rng = RandomNumberGenerator.new()
func randomize_vector_initial():
	while(waiting_to_begin):
		var rand_pos_1 = rng.randi_range(1, 30)
		var rand_pos_2 = rng.randi_range(1, 30)
		var rand_pos_3 = rng.randi_range(1, 30)
		var rand_pos_4 = rng.randi_range(1, 30)
		var rand_pos_5 = rng.randi_range(1, 30)
		await get_tree().create_timer(0.05).timeout

		var rand_positions = [rand_pos_1, rand_pos_2, rand_pos_3, rand_pos_4, rand_pos_5]
		set_boxes(rand_positions)
	
func randomize_vector():
	var start_time = int(Time.get_unix_time_from_system())
	var actual_time = 0
	var rand_positions : Array = []
	var rand_pos_1 = rng.randi_range(1, 30)
	var rand_pos_2 = rng.randi_range(1, 30)
	var rand_pos_3 = rng.randi_range(1, 30)
	var rand_pos_4 = rng.randi_range(1, 30)
	var rand_pos_5 = rng.randi_range(1, 30)
	print("RAND")
	while(actual_time - start_time < 5):
		actual_time = int(Time.get_unix_time_from_system())
		
		if actual_time - start_time == 0:
			rand_pos_1 = rng.randi_range(1, 30)
			rand_pos_2 = rng.randi_range(1, 30)
			rand_pos_3 = rng.randi_range(1, 30)
			rand_pos_4 = rng.randi_range(1, 30)
			rand_pos_5 = rng.randi_range(1, 30)
		elif actual_time - start_time == 1:
			rand_pos_2 = rng.randi_range(1, 30)
			rand_pos_3 = rng.randi_range(1, 30)
			rand_pos_4 = rng.randi_range(1, 30)
			rand_pos_5 = rng.randi_range(1, 30)
		elif actual_time - start_time == 2:
			rand_pos_3 = rng.randi_range(1, 30)
			rand_pos_4 = rng.randi_range(1, 30)
			rand_pos_5 = rng.randi_range(1, 30)
		elif actual_time - start_time == 3:
			rand_pos_4 = rng.randi_range(1, 30)
			rand_pos_5 = rng.randi_range(1, 30)
		elif actual_time - start_time == 4:
			rand_pos_5 = rng.randi_range(1, 30)
		print("RAND")
		await get_tree().create_timer(0.05).timeout

		rand_positions = [rand_pos_1, rand_pos_2, rand_pos_3, rand_pos_4, rand_pos_5]
		set_boxes(rand_positions)
	
	print("rand_positions:", rand_positions)
	
	var new_box_states : Array = []
	new_box_states.append(rand_positions.duplicate(true))
	#new_box_states.append(rand_positions)
	print("new_box_states:", new_box_states)
	bubbleSort(new_box_states, rand_positions)
	#new_box_states.insert(0, rand_positions.duplicate(true))
	print(new_box_states)
	box_states = new_box_states

# Called when the node enters the scene tree for the first time.
func _ready():
	ideInstructions.bbcode_text = """[center][font_size=12][b]Instrucciones[/b][/font_size][/center]
	Bitama usa la llave que encontró para abrir la puerta de los aposentos.
Allí, se encuentra con que hay una trampa que corta el paso hacia el final de la habitación. Para desactivarla, deberá introducir el código secreto, el cual se forma ingresando los valores de la caja presentes en la sala de manera ascendente. El usuario deberá implementar un algoritmo para ordenar las cajas y obtener la clave.

Tu tarea consiste en implementar la función [color=red]ordenarVector()[/color], la cual recibe como parámetros el
vector con diferentes números en un estado desordenado. Este debe idear un algoritmo que ordene los números del vector.

Siguiendo esta lógica, por ejemplo, el siguiente vector:

[b][ 15, 8, 1, 5, 12 ][/b]

Debería dejarlo en el estado:

[b][ 1, 5, 8, 12, 15 ][/b]
"""

	var codeLines: Array[String] =[
		"function ordenarVector(vector) {",
		"",
		"}"
	]
	ide.set_code(codeLines)
	ide.set_ide_visible(false)
	ApiService.connect("signalApiResponse", process_response)

	ide.connect("executeCodeSignal", send_code)
	
	destination_position = $"Vector/BoxPosition-5".global_position
	randomize_vector_initial()
	var state : Array = box_states[0] 
	set_boxes(state)
	
	var playerSteps: Array[Vector2] = [ 
		BoxPosition_Inicio_1.global_position,
		BoxPosition_Inicio_2.global_position
	]
	player.update_destination(playerSteps)
	await player.npcArrived
	player.connect("npcArrived",player_arrived)
	talk_master()

	#const intruction_dialogs : Array[String] = [
	#		"Hola!!!",
	#		"El siguiente paso en tu camino ..",
	#		".. es una tarea un poco mas compleja",
	#		"Programa una función para ordenar los numeros de las cajas",
	#	]
	#DialogManager.start_dialog(Vector2(115,160),intruction_dialogs, {'auto_play_time': 0.7})

	await DialogManager.signalCloseDialog
	
	ide.set_ide_visible(true)


func set_boxes(values: Array):
	Box_1.set_number(values[0])
	Box_2.set_number(values[1])
	Box_3.set_number(values[2])
	Box_4.set_number(values[3])
	Box_5.set_number(values[4])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func player_arrived():
	
	if isReturningFromBox:
		print("Returning form box")
		var playerSteps: Array[Vector2]
		playerSteps = [
			current_box_path_position.global_position,
		]
		
		set_boxes(box_states[number_current_box])
		number_current_box += 1
		isReturningFromBox = false
		player.update_destination(playerSteps)
		
		if (number_current_box == box_states.size()):
			
			master.update_phrases(vector_sorted_message, Vector2(110,140), true, {'auto_play_time': 1, 'close_by_signal': true})
			print("Finished sort")
			await DialogManager.signalCloseDialog
			LevelManager.load_demo_scene(get_tree().current_scene.scene_file_path, nextLevel, "VECTORES", "Nivel VII", "Buscando la llave")

	elif number_current_box < box_states.size():
		print("Not First Call")
		print(box_states[number_current_box])
		print(box_states[number_current_box -1])

		var pos_changed = first_different_position(box_states[number_current_box], box_states[number_current_box - 1])
		print("pos changed: ", pos_changed)
		move_to_box_by_number(pos_changed + 1)
		
		isReturningFromBox = true
	
	#&& !isReturningFromBox):
		
		#ExecutionResult.set_visible(true)
		#ExecutionResult.setContratulations()
	

func first_different_position(array1: Array, array2: Array) -> int:
	print(array1, array2)
	var min_size = min(array1.size(), array2.size())
	for i in range(min_size):
		if array1[i] != array2[i]:
			return i

	return -1  # If arrays are identical up to min_size, return -1 to indicate no difference

func talk_master():
	var phrases: Array[String] = []

	phrases = [
		"Bienvenido, es hora de masterizar tus habilidades de ordenamiento", 
		"Para eso deberas crear un algoritmo que ordene estas cajas mágicas",
		"Donde inicialmente no sabes que valor tiene cada una"
	]
	master.update_phrases(phrases, Vector2(110,140), true, {'auto_play_time': 1, 'close_by_signal': true})

func move_to_box_by_number(box_number: int):
	print(box_number)
	match box_number:
		1:
			move_to_box(BoxPosition_1, Box_1)
		2:
			move_to_box(BoxPosition_2, Box_2)
		3:
			move_to_box(BoxPosition_3, Box_3)
		4:
			move_to_box(BoxPosition_4, Box_4)
		5:
			move_to_box(BoxPosition_5, Box_5)

func move_to_box(box_path_position, box):
	var playerSteps: Array[Vector2]
	playerSteps = [
		box_path_position.global_position,
		box.global_position,
	]
	
	current_box = box
	current_box_path_position = box_path_position
	player.update_destination(playerSteps)
	
func send_code(code):
	
	print(code)
	ApiService.send_request(code, HTTPClient.METHOD_POST, "sort-vector")
	await ApiService.signalApiResponse
	
	print("RESPUESTA DESDE SEND CODE")
	print(response)
	
	##if response.code == 500:
	#	ExecutionResult.set_visible(true)
	#	ExecutionResult.setCompilationError(response.message)
		#return
	
	
	
	waiting_to_begin = false
	
	var phrases: Array[String] = []
	phrases = [
		"Las cajas estan adquiriendo un valor!!!!!"
	]
	master.update_phrases(phrases, Vector2(110,140), true, {'auto_play_time': 1, 'close_by_signal': true})

	await randomize_vector()
	
	print("SENDCODE")
	print(box_states)
	number_current_box = 1
	var pos_changed = first_different_position(box_states[number_current_box], box_states[0])
	move_to_box_by_number(pos_changed + 1)
	pass
	
func bubbleSort(arrList: Array, arr: Array):
	var n = arr.size()
	for i in range(n - 1):
		for j in range(n - i - 1):
			if arr[j] > arr[j + 1]:
				# Swap elements if they are in the wrong order
				var temp = arr[j]
				arr[j] = arr[j + 1]
				arrList.append(arr.duplicate(true))
				arr[j + 1] = temp
				arrList.append(arr.duplicate(true))


func process_response(resp):
	response = resp
	print("RESPUESTA:")
	print(resp)
	response = resp
	#emit_signal(response_ready)
	#ExecutionResult.set_visible(true)
	#ExecutionResult.setContratulations()
	print(resp.code)
	pass
