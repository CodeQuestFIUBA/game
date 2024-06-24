extends Node2D

signal coordinatesReady(coords, params, result, expected_result);
@onready var ide = $CanvasLayer/IDE;
@onready var matrix = $ObjectMatrix;
@onready var leader = $VillageLeader;
@onready var player = $Player;
@onready var key = $Key;

var dialog_position = Vector2(12, 176);
var player_position: Array[Vector2] = [Vector2(12,120)]
var leader_intro_dialog: Array[String] = [
	"Oh! Por fín vino alguien a ayudarnos.",
	"Mi nombre es Sun Dong, soy el líder de la aldea.",
	"Lamentablemente, hace algunos días el maléfico Matrix Worm tomó el control del área.",
	"Llegó, derrotó a nuestros guerreros, entró a mi casa, ...",
	"lanzó todas mis pertenecias aquí y se instaló en mis aposentos.",
	"Por miedo, la gente comenzó a huir despavorida hacia otras zonas.",
	"Sin embargo, a mí me tomaron como prisionero y me obligan a mantener el jardín.",
	"Si vienes a ayudarnos, hay una llave de respaldo dentro de una de estas canastas.",
	"Revisa cada una de ellas y encuéntrala.",
	"Es la única manera de ingresar y derrotarlo.",
	"¡Por favor, ayúdanos!"
];

var leader_key_found: Array[String] = [
	"¡Excelente! Has encontrado la llave.",
];

var leader_bye: Array[String] = [
	"Ahora ve y derrota a ese ninja perverso.",
];

func _ready():
	if ApiService:
		ApiService.connect("signalApiResponse", process_response)
	ApiService.login("gonza@gmail.com", "Test123123");
	var initialCode: Array[String] = ["function buscarLlave(matriz, anchoMatriz, altoMatriz) {", "    return true;", "}"]
	ide.set_code(initialCode)
	ide.connect("executeCodeSignal", send_request)
	matrix.connect("matrixAnimationFinished", on_key_found);
	run_intro();

func send_request(body = null):
	ApiService.send_request(body, HTTPClient.METHOD_POST, "search-matrix");

func process_response(res):
	if !res: 
		print("Error");
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
	player.update_destination(player_position);
	await player.npcArrived;
	leader.update_phrases(
		leader_intro_dialog, 
		dialog_position, 
		true, 
		{'auto_play_time': 1, 'close_by_signal': true});
	await DialogManager.signalCloseDialog
		
func on_key_found(coords: Vector2i):
	key.show_key(coords);
	leader.update_phrases(
		leader_key_found, 
		dialog_position, 
		true, 
		{'auto_play_time': 1, 'close_by_signal': true});
	await DialogManager.signalCloseDialog
	key.move_to($AirPos)
	await key.keyArrivedDestination
	leader.update_phrases(
		leader_bye, 
		dialog_position, 
		true, 
		{'auto_play_time': 1, 'close_by_signal': true});
	await DialogManager.signalCloseDialog		
	key.move_to($FinalPos)
	
