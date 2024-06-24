extends Node2D

@onready var fog: TextureRect = $"Fog"

# Called when the node enters the scene tree for the first time.
func _ready():
	fog.active = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
