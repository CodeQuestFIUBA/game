extends Node2D

const boss_level = "res://levels/Bosses/VectorsBoss.tscn"

@onready var challengesDoor = $ChallengeDoor
@onready var practicesDoor = $PracticesDoor

func _ready():
	LevelManager.progress_updated.connect(update_doors)

func _on_player_detector_body_entered(body: Node2D) -> void:
	RoomEvents.room_entered.emit(self)

func _on_boss_body_entered(body):
	LevelManager.load_scene(get_tree().current_scene.scene_file_path, boss_level)

func update_doors():
	var arrays_progress = LevelManager.get_level("vectores")
	var good_practices_progress = LevelManager.get_level("buenas_practicas")
	
	if arrays_progress[arrays_progress.size() - 1].completed:
		practicesDoor.visible = false
		practicesDoor.get_node('CollisionShape2D').disabled = true
		
	if good_practices_progress[0].completed:
		challengesDoor.visible = false
		challengesDoor.get_node('CollisionShape2D').disabled = true
