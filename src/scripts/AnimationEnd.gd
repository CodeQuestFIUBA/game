extends AnimationPlayer



func _ready():
	if DialogManager:
		DialogManager.connect("signalCloseDialog", animate_end_game)


func animate_end_game():
	pass
