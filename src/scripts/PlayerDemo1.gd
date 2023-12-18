extends CharacterBody2D

var showDialog = false

const lines: Array[String] = [
	"¡Hola, bienvendio al tutorial de CodeQuest!",
	"Vamos a empezar de a poco...",
	"En el IDE de la izquierda puedes escribir tu codigo...",
	"Muevete a la derecha escribiendo moveRight()"
]


func _ready():
	var animation_nodes = get_tree().get_nodes_in_group("animation")
	if animation_nodes.size() > 0:
		var animation = animation_nodes[0] as AnimationPlayer
		animation.connect("signalFinishedAnimation",on_signal_received)


func on_signal_received(arg):
	if !showDialog:
		DialogManager.start_dialog(global_position, lines)
	showDialog = true
