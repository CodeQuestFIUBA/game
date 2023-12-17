extends Node2D
signal level_completed(thisLevel)
@onready var player = $Player
@onready var sensei = $SenseiLevel1
@onready var animationEnd = $AnimationPlayer2

var rightOrders = ["moveLeft()", "moveUp()", "moveDown()", "moveRight()"]
var actualIndex = 0

const nextLines = {
	"moveLeft()": [
		"Muy bien, asi se hace...",
		"Ahora muevete arriba escribiendo moveUp()"
	],
	"moveUp()": [
		"Perfecto, asi se hace...",
		"Ahora muevete abajo escribiendo moveDown()"
	],
	"moveDown()": [
		"Fantastico, asi se hace...",
		"Ahora acercate a mi escribiendo moveRight()"
	],
	"moveRight()": [
		"Fabuloso, asi se hace...",
		"Lograste completa el tutorial...",
		"Ahora estas listo para nuevos desafios...",
		"Mucha suerte..."
	]
}

const wrongLines:  = {
	"moveLeft()": [
		"Volvamos a intentarlo...",
		"Muevete a la izq. escribiendo moveLeft()"
	],
	"moveUp()": [
		"Volvamos a intentarlo...",
		"Muevete arriba escribiendo moveUp()"
	],
	"moveDown()": [
		"Volvamos a intentarlo...",
		"Muevete abajo escribiendo moveDown()"
	],
	"moveRight()": [
		"Volvamos a intentarlo...",
		"Acercate a mi escribiendo moveRight()"
	]
}


# Called when the node enters the scene tree for the first time.
func _ready():
	var ide_nodes = get_tree().get_nodes_in_group("ide")
	if ide_nodes.size() > 0:
		var ide = ide_nodes[0] as Control
		ide.connect("mySignal",on_signal_received)
	if DialogManager:
		DialogManager.connect("signalCloseDialog", animate_end_game)


func animate_end_game():
	(animationEnd as AnimationPlayer).play("player_end")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var open_ide_press = Input.get_action_strength("show_ide")
	if open_ide_press == 1:
		show_ide()

func _on_player_door_opened():
	print(self.name + " completed")
	level_completed.emit(self.name)
	get_tree().change_scene_to_file("res://levels/Level1.tscn")


func show_ide():
	var ide_nodes = get_tree().get_nodes_in_group("ide")
	if ide_nodes.size() > 0:
		var ide = ide_nodes[0] as Control
		if ide.visible == false:
			ide.visible = true


func on_signal_received(arg):
	print(rightOrders.size())
	if (actualIndex == rightOrders.size()):
		return
	if (rightOrders[actualIndex] != arg):
		show_error_messages()
		return
	show_next_messages()
	actualIndex +=1
	if player:
		var positionToMove = {"left": 0, "right": 0, "up": 0, "down": 0}
		match arg:
			"moveLeft()":
				positionToMove.left = 1
			"moveRight()":
				positionToMove.right = 1
			"moveDown()":
				positionToMove.down = 1
			"moveUp()":
				positionToMove.up = 1
		for i in range(25):
			player.move_player(positionToMove)
			await get_tree().create_timer(0.016).timeout

func cast_array(array: Array[Variant]):
	var casted_array: Array[String] = []
	for i in array:
		casted_array.append(i as String)
	return casted_array

func show_error_messages():
	var lines:Array[String] = cast_array(wrongLines[rightOrders[actualIndex]])
	DialogManager.reset_dialog(sensei.global_position, lines)
	
func show_next_messages():
	var lines:Array[String] = cast_array(nextLines[rightOrders[actualIndex]])
	var closeLastDialog = actualIndex == rightOrders.size() - 1 
	DialogManager.reset_dialog(sensei.global_position, lines, closeLastDialog)
