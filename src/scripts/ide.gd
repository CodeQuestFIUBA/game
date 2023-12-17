extends Control

signal mySignal(signalArgument)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _process(delta):
	pass


func _on_button_execute_pressed():
	var code_edit_nodes = get_tree().get_nodes_in_group("codeEdit")
	if code_edit_nodes.size() > 0:
		var code_edit = code_edit_nodes[0] as CodeEdit
		var code = code_edit.text
		#fetch(code)
		request_demo(code)
	

func _on_button_close_pressed():
	self.visible = false

func request_demo(code):
	emitting_function(code)

func fetch(code):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	var a = {"name": "Godette"}
	print(a.name)
	var body = JSON.new().stringify({"func": code})
	var error = http_request.request("http://localhost:3000/", ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _http_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	print(response)
	emitting_function(response)


func emitting_function(arg):
	emit_signal("mySignal", arg)
