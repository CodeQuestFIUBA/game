extends Node2D

@onready var ide = $CanvasLayer/IDE;

# Called when the node enters the scene tree for the first time.
func _ready():
	if ApiService:
		ApiService.connect("signalApiResponse", process_response)
	ApiService.login("gonza@gmail.com", "Test123123");
	var initialCode: Array[String] = ["function test(value) {", "    return true;", "}"]
	ide.set_code(initialCode)
	ide.connect("executeCodeSignal", send_request)

func send_request(body = null):
	ApiService.send_request(body, HTTPClient.METHOD_GET, "ping");

func process_response(res):
	print(res);
	
