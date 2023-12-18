extends AnimationPlayer

signal signalFinishedAnimation(arg)
signal signalStartedAnimation(arg)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_animation_finished(anim_name):
	emit_signal("signalFinishedAnimation",anim_name)



func _on_animation_started(anim_name):
	emit_signal("signalStartedAnimation",anim_name)
