extends Node
const HTTP_OK = 200;
var token: String

signal signalApiResponse(signalArgument, extraArg)

func _process_request(body, type, route, success_cb, requires_auth, extraArg = null):
	var headers = ["Content-Type: application/json"];
	if requires_auth:
		headers.append("Authorization: Bearer " + token);
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(success_cb.bind(extraArg))
	var error = http_request.request("https://api.julif.com.ar/"+route, headers, type, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _http_request_completed(result, response_code, headers, body, extraArg):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	emitting_function(response, extraArg)

func _on_login_completed(result, response_code, headers, body, extraArg):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	if (response.code == 200):
		token = response.data.token
	emitting_function(response, extraArg)
	
func send_request(code, type, route, extraArg = null):
	_process_request(code, type, route, self._http_request_completed, true, extraArg);

func emitting_function(arg, extraArg = null):
	emit_signal("signalApiResponse", arg, extraArg)

func login(email, password, extraArg = "LOGIN"):
	var body = JSON.new().stringify({
		"email": email,
		"password": password
		})
	_process_request(body, HTTPClient.METHOD_POST, "users/login", self._on_login_completed, false, extraArg);


func register(body, extraArg = null):
	_process_request(body, HTTPClient.METHOD_POST, "users/signup", self._on_login_completed, false, extraArg);
