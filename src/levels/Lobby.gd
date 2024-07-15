extends Node

var user_logged = false

func _ready():
	Session.session_updated.connect(update_levels)
	update_levels()

func update_levels():
	LevelManager.update_levels()
