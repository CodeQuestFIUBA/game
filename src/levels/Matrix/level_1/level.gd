extends Node2D

# Falta meter al maestro y abrir la puerta al final

signal coordinatesReady(coords, params, result, expected_result);
@onready var ide = $CanvasLayer/IDE;
@onready var matrix = $ObjectMatrix;
@onready var slave = $Slave;
@onready var player = $Player;
@onready var key = $Key;
@onready var key_not_found = $KeyNotFound;
@onready var sensei = $Sensei;
@onready var door = $OpenedDoor;


var slave_dialog_position = Vector2(54, 164);
var sensei_dialog_position = Vector2(180, 104);
var player_position: Array[Vector2] = [Vector2(12,128)]
var sensei_position: Array[Vector2] = [Vector2(240,64), Vector2(296,88)]
var sensei_intro_dialog: Array[String] = [
	"Kimono se encuentra detrás de esa puerta.",
	"Ya no tiene dónde huir.",
	"Tenemos que hallar la manera de abrirnos camino."
];
var slave_intro_dialog: Array[String] = [
	"Con que vienen detrás de Kimono",
	"Hace semanas que me mantiene aquí cautivo",
	"Por favor, derrotenlo y libérenme. ¡Se los suplico!",
	"Sé que guarda una llave de repuesto en alguna parte de esta habitación,",
	"pero con este desorden es imposible saber dónde.",
	"Quizás debas mirar todos los canastos hasta encontrarla."
];

var slave_key_found: Array[String] = [
	"¡Excelente! Has encontrado la llave.",
];

var slave_bye: Array[String] = [
	"Ahora ve y derrota a ese ninja perverso.",
];

func _ready():
	if ApiService:
		ApiService.connect("signalApiResponse", process_response)
	door.visible = false;
	var initialCode: Array[String] = ["function buscarLlave(matriz, anchoMatriz, altoMatriz) {", "    return true;", "}"]
	ide.set_code(initialCode)
	ide.set_ide_visible(false)
	ide.connect("executeCodeSignal", send_request)
	matrix.connect("matrixAnimationFinished", on_matrix_iterated);
	run_intro();

func send_request(body = null):
	key_not_found.hide_element();
	ApiService.send_request(body, HTTPClient.METHOD_POST, "search-matrix", "MATRIX");

func process_response(res, extraArg):
	if extraArg != "MATRIX": return
	if !res: 
		_show_error("Esto es raro. Ocurrió un error desconocido.");
		return;

	if res.code != 200:
		_show_error(res.message);
		return;
	
	if !(typeof(res.data.result) == TYPE_DICTIONARY) || !res.data.result.has("x") || !res.data.result.has("y"):
		_show_error("El valor retornado no tiene el formato esperado.");
		return;
	
	if res.data.variableTrace.size() == 0:
		_show_error("Mmmm, parece que tu solución no está recorriendo la matriz.");
		return;
		
	var numeric_coordinates: Array[Vector2i] = [];
	for string_coord in res.data.variableTrace:
		var numeric_coord = JSON.parse_string(string_coord);
		numeric_coordinates.append(Vector2i(numeric_coord[0], numeric_coord[1]));

	emit_signal("coordinatesReady", 
		numeric_coordinates, 
		res.data.params,
		res.data.result,
		res.data.expectedResult);
		
func run_intro():
	sensei.update_destination(sensei_position);
	player.update_destination(player_position);
	await player.npcArrived;
	await sensei.npcArrived;
	_make_npc_talk(sensei_intro_dialog, sensei, sensei_dialog_position)	
	await DialogManager.signalCloseDialog;
	_make_npc_talk(slave_intro_dialog, slave, slave_dialog_position)	
	await DialogManager.signalCloseDialog
	ide.set_ide_visible(true)
		
func on_matrix_iterated(coords: Vector2i, success: bool):
	if !success:
		key_not_found.show_element(coords)
		var error_message: Array[String] = ["Mmmm, parece que aquí no está la llave.", "Inténtalo de nuevo"]
		slave.update_phrases(
			error_message, 
			slave_dialog_position, 
			true, 
			{'auto_play_time': 1, 'close_by_signal': true});
		return
		
	key.show_key(coords);
	_make_npc_talk(slave_key_found, slave, slave_dialog_position)
	await DialogManager.signalCloseDialog
	key.move_to($AirPos)
	await key.keyArrivedDestination
	_make_npc_talk(slave_bye, slave, slave_dialog_position)
	await DialogManager.signalCloseDialog
	key.move_to($FinalPos)
	await get_tree().create_timer(3).timeout
	_run_outro()
	
func _show_error(message: String):
	var error_message: Array[String] = [message, "Inténtalo de nuevo"]
	slave.update_phrases(
		error_message, 
		sensei_dialog_position, 
		true, 
		{'auto_play_time': 1, 'close_by_signal': true});
	return;

func _make_npc_talk(messages: Array[String], npc, dialog_position):
	npc.update_phrases(
		messages, 
		dialog_position, 
		true, 
		{'auto_play_time': 1, 'close_by_signal': true});
	return;

func _run_outro():
	door.visible = true
	await get_tree().create_timer(0.4).timeout
	LevelManager.load_scene(get_tree().current_scene.scene_file_path, "res://levels/Bosses/VectorsBoss.tscn")
