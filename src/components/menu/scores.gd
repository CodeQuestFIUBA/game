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

var call_points = false

func _ready():
	if ApiService:
		ApiService.connect("signalApiResponse", process_response)
	ApiService.send_request("{}", HTTPClient.METHOD_GET, "score", "GET_POINTS")
	#ApiService.login("mafvidal35@gmail.com", "Asd123456+", "LOGIN_POINTS");
	myPointsButton.toggle_mode = true
	myPointsButton.set_pressed(true)
	classPointsButton.toggle_mode = true


func _process(delta):
	pass

func process_points(res):
	var scores = res["data"]["scoresByClassRoom"]
	var points = res["data"]["scores"]
	for point in points:
		addPoint(point)
	for i in range(scores.size()):
		addUserPoint(scores[i], i + 1)

func process_response(res, extraArg):
	match extraArg:
		"GET_POINTS": 
			if !res || res["code"] != 200:
				return
			process_points(res)

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
	#print(point.qualification == 0)
	match int(point.qualification):
		0: cupTexture.texture = load(noCup)
		1: cupTexture.texture = load(fistLevel)
		2: cupTexture.texture = load(secondLevel)
		3: cupTexture.texture = load(thirdLevel)
		_: cupTexture.texture = load(noCup)
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
