extends CharacterBody2D


const lines: Array[String] = [
	"¡Hola, bienvendio al tutorial de CodeQuest!",
	"Vamos a empezar de a poco...",
	"En el IDE de la izquierda puedes escribir tu codigo...",
	"Muevete a la derecha escribiendo moveRight()"
]


func _ready():
	var ide_nodes = get_tree().get_nodes_in_group("animation")
	if ide_nodes.size() > 0:
		var ide = ide_nodes[0] as AnimationPlayer
		ide.connect("signalFinishedAnimation",on_signal_received)


func on_signal_received():
	DialogManager.start_dialog(global_position, lines)
