extends Node

signal session_updated

var uid: String;
var firstName: String;
var lastName: String;
var token: String;
var refreshToken: String;
var email: String;

func update_session(data, id):
	if id != "LOGIN" && id != "REGISTER": return
	uid = data.user.user_id;
	firstName = data.user.first_name;
	lastName = data.user.last_name;
	email = data.user.email;
	token = data.token;
	refreshToken = data.refresh_token;
	session_updated.emit()
