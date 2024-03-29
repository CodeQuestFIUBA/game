extends Node2D

func _ready():
	$moveDown.setAction("Mover Abajo")
	$moveUp.setAction("Mover Arriba")
	$moveLeft.setAction("Mover Izquierda")
	$moveRight.setAction("Mover Derecha")

func _on_play_button_pressed():
	print("Boton Apretado!")
