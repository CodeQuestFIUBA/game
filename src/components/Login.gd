extends Control
#
@onready var pwd = $Container/Inputs/PasswordInput/PasswordInput;
@onready var email = $Container/Inputs/EmailInput/EmailInput;
@onready var loginButton = $LoginButton/Button;
@onready var errorMessage = $Error;
@onready var spinner = $Spinner;
var emailSent = "";
var pwdSent = "";
var isLoading = false;
var inputUpdated = false;

func _ready():
	spinner.visible = false;
	errorMessage.visible = false;
	ApiService.connect("signalApiResponse", _process_response);

func _process(delta):
	if (isLoading): return;
	loginButton.disabled = email.text == "" || pwd.text == "";
	if (!inputUpdated && (email.text != emailSent || pwd.text != pwdSent)):
		errorMessage.visible = false;
		inputUpdated = true;

func _on_button_pressed():
	emailSent = email.text;
	pwdSent = pwd.text
	GLOBAL.startLoading.emit();
	ApiService.login(emailSent, pwdSent);
	#ApiService.login("gonza@test.com", "Test123123");
	isLoading = true;
	loginButton.disabled = true;
	email.editable = false;
	pwd.editable = false;
	spinner.visible = true;
	inputUpdated = false;
	
func _process_response(response, extraArg):
	GLOBAL.stopLoading.emit();
	isLoading = false;
	spinner.visible = false;
	if (response.code == ApiService.HTTP_OK):
		Session.update_session(response.data, extraArg);
	else: 
		errorMessage.visible = true;
		loginButton.disabled = false;
		email.editable = true;
		pwd.editable = true;
	
	
	
