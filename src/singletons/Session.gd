extends Node

var uid: String;
var firstName: String;
var lastName: String;
var token: String;
var refreshToken: String;
var email: String;

func update_session(data):
	uid = data.user.user_id;
	firstName = data.user.first_name;
	lastName = data.user.last_name;
	email = data.user.email;
	token = data.token;
	refreshToken = data.refresh_token;
	
