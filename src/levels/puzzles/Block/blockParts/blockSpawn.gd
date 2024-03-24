extends StaticBody2D

signal onBlockDeleted(node :Node2D)
# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color(Color.GRAY, 0.4)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	visible = GlobalBlockTracking.is_dragging

func get_drop_position():
	return global_position

func handle_drop(dropped : Node2D):
	dropped.queue_free()
	onBlockDeleted.emit(dropped)
