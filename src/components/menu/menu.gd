extends Control

@onready var panelContainer = $PanelContainer
@onready var logo = $Logo
@onready var close = $Close
@onready var menu = $Menu
@onready var back = $Back
@onready var container = $"."
@onready var scores = $scores
@onready var encyclopedia = $Encyclopedia

# Called when the node enters the scene tree for the first time.
func _ready():
	set_menu_visible(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_menu_visible(value: bool):
	if !value:
		container.size.x = 46
		container.size.y = 14
	else:
		container.size.x = 400
		container.size.y = 224


func _on_menu_pressed():
	set_menu_visible(true)
	logo.visible = true
	close.visible = true
	logo.visible = true
	panelContainer.visible = true
	menu.visible = false


func _on_close_pressed():
	set_menu_visible(false)
	logo.visible = false
	close.visible = false
	logo.visible = false
	panelContainer.visible = false
	menu.visible = true


func _on_points_pressed():
	scores.visible = true
	logo.visible = false
	close.visible = false
	logo.visible = false
	panelContainer.visible = false
	menu.visible = false
	back.visible = true


func _on_back_pressed():
	back.visible = false
	logo.visible = true
	close.visible = true
	logo.visible = true
	panelContainer.visible = true
	scores.visible = false
	menu.visible = false
	encyclopedia.visible = false
	


func _on_button_doc_pressed():
	encyclopedia.visible = true
	logo.visible = false
	close.visible = false
	logo.visible = false
	panelContainer.visible = false
	menu.visible = false
	back.visible = true
