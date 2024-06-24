extends Node
const HTTP_OK = 200;
var token: String

signal signalApiResponse(signalArgument)

func _process_request(body, type, route, success_cb, requires_auth):
	var headers = ["Content-Type: application/json"];
	if requires_auth:
		headers.append("Authorization: Bearer " + token);
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(success_cb)
	var error = http_request.request("http://localhost:8080/"+route, headers, type, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _http_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	print(response)
	emitting_function(response)

func _on_login_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	print(response)
	emitting_function(response)
	if (response.code == 200):
		token = response.data.token
	
func send_request(code, type, route):
	#var body = JSON.new().stringify({"func": code})
	#print("MESSI ", body);
	_process_request(code, type, route, self._http_request_completed, true);

func emitting_function(arg):
	emit_signal("signalApiResponse", arg)

func login(email, password):
	var body = JSON.new().stringify({
		"email": email,
		"password": password
		})
	_process_request(body, HTTPClient.METHOD_POST, "users/login", self._on_login_completed, false);
