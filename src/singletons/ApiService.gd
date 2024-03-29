extends Node

signal signalApiResponse(signalArgument)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func send_request(code, type, route):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	var a = {"name": "Godette"}
	print(a.name)
	var body = JSON.new().stringify({"func": code})
	var error = http_request.request("http://localhost:3000/"+route, ["Content-Type: application/json"], type, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	

func _http_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	print(response)
	emitting_function(response)


func emitting_function(arg):
	emit_signal("signalApiResponse", arg)
