extends Node

@onready var boss = $Boss
@onready var instruction = $Boss/CanvasLayer/IDE/Instructions/MarginContainer/Instructions
# Called when the node enters the scene tree for the first time.
func _ready():
	boss.questions = questions
	boss.codeLines = codeLines
	boss.post_quiz_phrases = post_quiz_phrases
	boss.intro_phrases = intro_phrases
	boss.help_phrases = help_phrases
	boss.check_if_result_is_correct = check_if_result_is_correct
	boss.request_path = "vectors/boss"
	boss.add_attempt_path = "score/attempts/vectores/7"
	boss.add_complete_path ="score/complete/vectores/7"
	
	instruction.bbcode_text = """[center][font_size=12][b]Instrucciones[/b][/font_size][/center]
	Bitama quiere propinarle a su enemigo la mayor cantidad de ataques posibles. Si bien el daño que infrinja cada uno no es relevante, sí lo es la cantidad de energía que requiere cada jutsu.
	Recibirás un vector con la energía que consumen los jutsus y la energía de la que dispone Bitama, y deberás retornar la mayor cantidad de ataques posibles que puede realizar.
	Ejemplo: Si la energía que dispone es de 9, y la lista de jutsus es:
	[b][1 4 12 6 9 1 2 3 1 4][/b]
	Se debería devolver 5, ya que se podrán realizar aquellos que consumen energía [b][1 1 2 3 1][/b]."""

func check_if_result_is_correct():
	print("Verificando respuesta")
	return true

var help_phrases: Array[String] = [
		"Esta es una ayuda",
		"Esta es otra ayuda"
	]

var intro_phrases: Array[String] = [
		"Asi que al fin nos encontramos...", 
		"Soy el gram Quickslash Kimono",
		"Nuestra batalla sera legendaria"
	]

var post_quiz_phrases: Array[String] = [
		"Deberas resolver este desafio \npara poder derrotarme"
	]

var codeLines: Array[String] = [
	"function pelear(cantidadEnemigos, armaEnemigo) {",
	"	//Ninjaku gana a Sai",
	"	//Sai gana a Whip",
	"	//Whip gana a Katana",
	"	//Katana gana a Ninjaku",
	"	",
	"	return {",
	"		arma: ''",
	"		total: 0",
	"	}",
	"}"]

var questions = [
	{
		"question": "¿Qué devuelve la propiedad \"length\" de un arreglo? \n[center][img=150]res://sprites/encyclopedia/algoritmo.png[/img][/center]",
		"answers": [
			"El número máximo de elementos que puede contener el arreglo",
			"El número de elementos que actualmente tiene el arreglo",
			"El tamaño del arreglo en bytes",
			"El tamaño del arreglo subyacente"
			], "correct": 1
	},
	{
		"question": "¿Cómo se accede al tercer elemento de un arreglo llamado arr?",
		"answers": [
			"arr[2];", 
			"arr.at(2);",
			"arr[3];",
			"Tanto A como B"
			], "correct": 3
	},
	{
		"question": "¿Qué sucede si intentas acceder a un elemento fuera de los límites de un arreglo en JavaScript?",
		"answers": [
			"Devuelve \"undefined\"", 
			"Lanza una excepción",
			"Causa un error en tiempo de ejecución",
			"Devuelve el último elemento del arreglo"
			], "correct": 0
	},{
		"question": "¿Cuál de las siguientes opciones inicializa correctamente un arreglo vacío en JavaScript?",
		"answers": [
			"let arr = [];", 
			"let arr = new Array();",
			"let arr = Array();",
			"Todas las anteriores"
			], "correct": 3
	},{
		"question": "¿Cómo se accede al tercer elemento de un arreglo llamado arr?",
		"answers": [
			"arr[2];", 
			"arr.at(2);",
			"arr[3];",
			"Tanto A como B"
			], "correct": 3
	},
	# Add more questions as needed
]
