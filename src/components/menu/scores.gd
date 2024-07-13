extends Control

@onready var myPointsButton: Button = $PanelContainer/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer2/PanelContainer/Button
@onready var classPointsButton: Button = $PanelContainer/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer2/PanelContainer2/Button
@onready var myPointsContainer = $PanelContainer/MarginContainer/VBoxContainer/MyPointsContainer
@onready var myClassContainer = $PanelContainer/MarginContainer/VBoxContainer/MyClassPoints
@onready var pointsList = $PanelContainer/MarginContainer/VBoxContainer/MyPointsContainer/MarginContainer/ScrollContainer/VBoxContainer
@onready var classPoints = $PanelContainer/MarginContainer/VBoxContainer/MyClassPoints/MarginContainer/ScrollContainer/VBoxContainer
@onready var pointsContainerLevel = $PanelContainer/MarginContainer/VBoxContainer/MyPointsContainer/MarginContainer/ScrollContainer/VBoxContainer/pointContainer
@onready var userPointsContainerLevel = $PanelContainer/MarginContainer/VBoxContainer/MyClassPoints/MarginContainer/ScrollContainer/VBoxContainer/userPointContainer
@onready var fistLevel = "res://sprites/objects/goldCup.png"
@onready var secondLevel = "res://sprites/objects/silverCup.png"
@onready var thirdLevel = "res://sprites/objects/bronzeCup.png"
@onready var noCup = "res://sprites/objects/noCup.png"

var points = [
	{
		"level": "Programación basica 1",
		"complete": true,
		"score": 300,
		"qualification": 1
	},
	{
		"level": "Programación basica 2",
		"complete": true,
		"score": 150,
		"qualification": 3
	},
	{
		"level": "Programación basica 3",
		"complete": false,
		"score": 0,
		"qualification": 0
	},
	{
		"level": "Funciones 1",
		"complete": true,
		"score": 150,
		"qualification": 2
	},
	{
		"level": "Funciones 2",
		"complete": false,
		"score": 0,
		"qualification": 0
	}
]

var scores = [
	{
		"user": "Gonzalo",
		"score": 350,
		"myUser": false
	},
	{
		"user": "Ezequiel",
		"score": 300,
		"myUser": false
	},
	{
		"user": "Nicolas",
		"score": 250,
		"myUser": false
	},
	{
		"user": "Mariano",
		"score": 100,
		"myUser": true
	},
	{
		"user": "Bruno",
		"score": 0,
		"myUser": false
	}
]

func _ready():
	myPointsButton.toggle_mode = true
	myPointsButton.set_pressed(true)
	classPointsButton.toggle_mode = true
	for point in points:
		addPoint(point)
	print(scores)
	for i in range(scores.size()):
		addUserPoint(scores[i], i + 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func addPoint(point):
	var pointsContainer = pointsContainerLevel.duplicate()
	pointsContainer.visible = true
	var childs = pointsContainer.get_children()[1].get_children()[0].get_children()
	var cupContainer = childs[0]
	var cupTexture: TextureRect = cupContainer.get_children()[0] 
	var level = childs[1]
	var score = childs[3]
	level.text = point.level
	score.text = str(point.score) + " Pts"
	match point.qualification:
		0: cupTexture.texture = load(noCup)
		1: cupTexture.texture = load(fistLevel)
		2: cupTexture.texture = load(secondLevel)
		3: cupTexture.texture = load(thirdLevel)
	pointsList.add_child(pointsContainer)


func addUserPoint(score, pos):
	var pointsContainer = userPointsContainerLevel.duplicate()
	pointsContainer.visible = true
	var childs = pointsContainer.get_children()[1].get_children()[0].get_children()
	var positionLabel = childs[0]
	var userLabel: Label = childs[1]
	var scoreLabel = childs[3]
	positionLabel.text = str(pos)
	userLabel.text = score.user
	if score.myUser:
		userLabel["theme_override_colors/font_color"] = Color(1.0,0.0,0.0,1.0)
	scoreLabel.text = str(score.score) + " Pts"
	classPoints.add_child(pointsContainer)


func _on_my_points_pressed():
	myPointsButton.set_pressed(true)
	classPointsButton.set_pressed(false)
	myPointsContainer.visible = true
	myClassContainer.visible = false


func _on_class_points_pressed():
	myPointsButton.set_pressed(false)
	classPointsButton.set_pressed(true)
	myPointsContainer.visible = false
	myClassContainer.visible = true
