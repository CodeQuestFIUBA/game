extends AnimationPlayer


signal signalFinishedAnimation()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_animation_finished(anim_name):
	emit_signal("signalFinishedAnimation")

