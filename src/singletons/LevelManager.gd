extends Node

signal progress_updated
signal load_demo_screen(level, sublevel, title, callback)

@export var loading_screen_path: String = "res://components/LoadingScreen.tscn"
@export var level_progress = [] 

var loading_screen: PackedScene
var current_loading_screen_instance: Node = null

func _ready():
	loading_screen = load(loading_screen_path)
	if ApiService:
		ApiService.connect("signalApiResponse", process_response)

func show_loading_screen():
	if loading_screen and not current_loading_screen_instance:
		current_loading_screen_instance = loading_screen.instantiate()
		var canvas_layer = CanvasLayer.new()
		canvas_layer.add_child(current_loading_screen_instance)
		get_tree().root.add_child(canvas_layer)
		GLOBAL.startLoading.emit()

func hide_loading_screen():
	if current_loading_screen_instance:
		current_loading_screen_instance.queue_free()
		current_loading_screen_instance = null
		GLOBAL.stopLoading.emit()

func load_scene(prev_scene: String, next_scene: String):
	show_loading_screen()
	await get_tree().create_timer(1.25).timeout
	get_tree().change_scene_to_file(next_scene)
	hide_loading_screen()
	
func load_demo_scene(prev_scene: String, next_scene: String, level: String, sublevel: String, title: String):
	show_loading_screen()
	await get_tree().create_timer(1.25).timeout
	load_demo_screen.emit(level, sublevel, title, 
		func(): 
			get_tree().change_scene_to_file(next_scene)
			hide_loading_screen()
	)

func update_levels():
	ApiService.send_request("", HTTPClient.METHOD_GET, "levels/actual", "UPDATE_PROGRESS")

func process_response(response, id):
	if id != "UPDATE_PROGRESS": return
	if !response["data"]: return
	level_progress = response["data"].levels
	progress_updated.emit()

func get_level(level_name):
	return level_progress.filter(func(lvl: Dictionary) -> bool:
		return lvl.get("level", "") == level_name
	)
