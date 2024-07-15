extends Control

@onready var nameInput = $Container/Inputs/NameInput/NameInput
@onready var lastNameInput = $Container/Inputs/LastNameInput/LastNameInput
@onready var emailInput = $Container/Inputs/EmailInput/EmailInput
@onready var classRoomInput = $Container/Inputs/ClassRoomInput/ClassRoomInput
@onready var userNameInput = $Container/Inputs/UserNameInput/UserNameInput
@onready var pwdInput = $Container/Inputs/PasswordInput/PasswordInput

@onready var pwd = $Container/Inputs/PasswordInput/PasswordInput
@onready var email = $Container/Inputs/NameInput/NameInput;
@onready var loginButton = $LoginButton/Button;
@onready var errorMessage = $Error;
@onready var spinner = $Spinner;

var nameSent = "";
var lastNameSent = "";
var emailSent = "";
var classRoomSent = "";
var userNameSent = "";
var pwdSent = "";

var isLoading = false;
var inputUpdated = false;

func _ready():
	spinner.visible = false;
	errorMessage.visible = false;
	ApiService.connect("signalApiResponse", _process_response);

func _process(delta):
	if (isLoading): return;
	loginButton.disabled = nameInput.text == "" || lastNameInput.text == "" || emailInput.text == "" || classRoomInput.text == "" || userNameInput.text == "" || pwdInput.text == "";
	if (!inputUpdated && (nameSent != nameInput.text || lastNameSent != lastNameInput.text || emailSent != emailInput.text || classRoomSent != classRoomInput.text || userNameSent != userNameInput.text || pwdSent != pwdInput.text)):
		errorMessage.visible = false;
		inputUpdated = true;

func _on_button_pressed():
	nameSent = nameInput.text;
	lastNameSent = lastNameInput.text;
	emailSent = emailInput.text;
	classRoomSent = classRoomInput.text;
	userNameSent = userNameInput.text;
	pwdSent = pwdInput.text;
	var body = JSON.new().stringify({
		"first_name": nameSent,
		"last_name": lastNameSent,
		"Password": pwdSent,
		"email": emailSent,
		"username": userNameSent,
		"class_room": classRoomSent
	})
	GLOBAL.startLoading.emit();
	ApiService.register(body, "REGISTER");
	isLoading = true;
	loginButton.disabled = true;
	nameInput.editable = false;
	lastNameInput.editable = false;
	emailInput.editable = false;
	classRoomInput.editable = false;
	userNameInput.editable = false;
	pwdInput.editable = false;
	spinner.visible = true;
	inputUpdated = false;
	
func _process_response(response, extraArg):
	if extraArg != "REGISTER":
		return
	GLOBAL.stopLoading.emit();
	isLoading = false;
	spinner.visible = false;
	if (response.code == ApiService.HTTP_OK):
		Session.update_session(response.data, extraArg);
	else: 
		errorMessage.visible = true;
		loginButton.disabled = false;
		nameInput.editable = true;
		lastNameInput.editable = true;
		emailInput.editable = true;
		classRoomInput.editable = true;
		userNameInput.editable = true;
		pwdInput.editable = true;

