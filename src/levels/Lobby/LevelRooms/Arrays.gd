extends Node2D

const LEVELS = {
	"level_1": "res://levels/seach/level_1.tscn",
	"level_2": "res://levels/seach/level_2.tscn",
	"level_3": "res://levels/seach/level_3.tscn", 
	"level_4": "res://levels/seach/level_1.tscn",
	"level_5": "res://levels/puzzles/Vectors/sort.tscn",
	"level_6": "res://levels/puzzles/Vectors/sort.tscn",
	"level_7": "res://levels/Matrix/level_1/level.tscn",
	"boss": "res://levels/Bosses/VectorsBoss.tscn",
}

@onready var firstDoor = $Door1
@onready var doors = [
	$Door2,
	$Door3,
	$Door4,
	$Door5,
	$Door6,
	$Door7,
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

func _on_level_6_body_entered(body):
	_start_level("level_6")

func _on_level_7_body_entered(body):
	_start_level("level_7")
	
func _on_boss_body_entered(body):
	_start_level("boss")

func update_doors():
	var functions_progress = LevelManager.get_level("funciones_y_operadores")
	var arrays_progress = LevelManager.get_level("vectores")
	
	if functions_progress[functions_progress.size()-1].completed:
		firstDoor.visible = false;
		firstDoor.get_node('CollisionShape2D').disabled = true
		
	for i in range(arrays_progress.size()-1):
		if arrays_progress[i].completed:
			doors[i].visible = false;
			doors[i].get_node('CollisionShape2D').disabled = true


