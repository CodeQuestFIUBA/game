extends Node2D
signal start_demo(next_scene)

@onready var modal = $Modal;
@onready var levelLabel = $Modal/Container/Level;
@onready var sublevelLabel = $Modal/Container/Sublevel;
@onready var titleLabel = $Modal/Container/Title;
var load_screen: Callable;

func _ready():
	LevelManager.connect("load_demo_screen", _load_labels)

func _load_labels(level: String, sublevel: String, title: String, callback):
	levelLabel.text = level;
	sublevelLabel.text = sublevel;
	titleLabel.text = title;
	modal.visible = true;
	load_screen = callback;

func _on_start_button_pressed():
	load_screen.call()
