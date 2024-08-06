extends Node2D

const LEVELS = {
	"level_1": "res://levels/IntroProgramming/level_1.tscn",
	"level_2": "res://levels/IntroProgramming/level_2.tscn",
	"level_3": "res://levels/IntroProgramming/level_3.tscn",
	"level_4": "res://levels/IntroProgramming/level_4.tscn",
	"level_5": "res://levels/IntroProgramming/level_5.tscn",
	"boss": "res://levels/Bosses/VectorsBoss.tscn",
}

@onready var firstDoor = $Door1
@onready var doors = [
	$Door2,
	$Door3,
	$Door4,
	$Door5,
	$BossDoor
]

func _ready():
	LevelManager.progress_updated.connect(update_doors)

func _on_player_detector_body_entered(body: Node2D) -> void:
	RoomEvents.room_entered.emit(self)

func _start_level(level_key: String) -> void:
	if LEVELS.has(level_key):
		LevelManager.load_scene(get_tree().current_scene.scene_file_path, LEVELS[level_key])
	else:
		print("Error: Level key not found.")

func _on_level_1_body_entered(body):
	_start_level("level_1")

func _on_level_2_body_entered(body):
	_start_level("level_2")

func _on_level_3_body_entered(body):
	_start_level("level_3")

func _on_level_4_body_entered(body):
	_start_level("level_4")

func _on_level_5_body_entered(body):
	_start_level("level_5")

func _on_boss_body_entered(body):
	_start_level("boss")

func update_doors():
	var intro_progress = LevelManager.get_level("introduction")
	var basics_progress = LevelManager.get_level("bases_de_la_programacion")
	
	if intro_progress[intro_progress.size()-1].completed:
		firstDoor.visible = false;
		firstDoor.get_node('CollisionShape2D').disabled = true
		
	for i in range(basics_progress.size()-1):
		if basics_progress[i].completed:
			doors[i].visible = false;
			doors[i].get_node('CollisionShape2D').disabled = true
