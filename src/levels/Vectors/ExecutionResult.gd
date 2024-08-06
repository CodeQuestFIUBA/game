extends Node2D

@onready var textBoxTexto = $"TextBoxTexto"
@onready var textBoxTitulo = $"TextBoxTitulo"

@onready var ReintentarButton = $"ReintentarButton"

# Called when the node enters the scene tree for the first time.
func _ready():
	#ReintentarButton.pressed.connect(self.retryPressed)
	#textBoxTexto.display_text("Hola")
	#textBoxTitulo.display_text("Hola como andas?")
	pass # Replace with function body.

func setCompilationError(err):
	#textBoxTitulo.restart_letter_index()
	#textBoxTexto.restart_letter_index()
	#textBoxTitulo.display_text("Error de compilación")
	#textBoxTexto.display_text(err)
	pass
func setContratulations():
	#textBoxTitulo.restart_letter_index()
	#textBoxTexto.restart_letter_index()
	#textBoxTitulo.display_text("Felicitaciones")
	#textBoxTexto.display_text("Haz completado el nivel correctamente")
	pass
func setFail():
	#textBoxTitulo.restart_letter_index()
	#textBoxTexto.restart_letter_index()
	#textBoxTitulo.display_text("Ups!")
	#textBoxTexto.display_text("Al parecer el código que escribiste no resuelve el problema correctamente")
	pass
	
func retryPressed():
	self.set_visible(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
