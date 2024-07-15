extends Control
signal closeOptions
@onready var label_container = $PanelContainer/MarginContainer/PanelContainer/MarginContainer/Options/ScrollContainer/VBoxContainer2/VBoxContainer
@onready var label_subOptions_container = $PanelContainer/MarginContainer/PanelContainer/MarginContainer/SubOptions/ScrollContainer/VBoxContainer2/VBoxContainer
@onready var labelButton: Button = $PanelContainer/MarginContainer/PanelContainer/MarginContainer/Options/ScrollContainer/VBoxContainer2/VBoxContainer/Button
@onready var labelSubptionsButton: Button = $PanelContainer/MarginContainer/PanelContainer/MarginContainer/SubOptions/ScrollContainer/VBoxContainer2/VBoxContainer/Button
@onready var fistScreen = $PanelContainer/MarginContainer/PanelContainer/MarginContainer/Options;
@onready var secondScreen = $PanelContainer/MarginContainer/PanelContainer/MarginContainer/SubOptions
@onready var thirdScreen = $PanelContainer/MarginContainer/PanelContainer/MarginContainer/VBoxContainer
@onready var title = $PanelContainer/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Label
@onready var content = $PanelContainer/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/Label
@onready var backContainer = $PanelContainer/MarginContainer/MarginContainer
@onready var closeButton = $PanelContainer/MarginContainer/MarginContainer2
@onready var titleButton = $PanelContainer/MarginContainer/MarginTitleContainer/TittleSection
#@onready var definicionAlgoritmo = $PanelContainer2/Algoritmo

var options = []


# Called when the node enters the scene tree for the first time.
func _ready():
	options = [
		{
			"title": "Introducción a la algoritmia",
			"subtemas": [
			{
				"title": "Definición de Algoritmo",
				"content": $PanelContainer2/Algoritmo 
			},
			{
				"title": "Condicionales",
				"content": $PanelContainer2/Condicionales
			},
			]
		},
		{
			"title": "Bases de la programación",
			"subtemas": [
			{
				"title": "Tipos de Datos",
				"content": $PanelContainer2/TiposDeDatos
			},
			{
				"title": "Estructuras de Control",
				"content": $PanelContainer2/EstructuraDeControl
			},
			{
				"title": "Sintaxis Básica",
				"content": $PanelContainer2/SintaxisYSemantica
			},
			{
				"title": "Entornos de Desarrollo",
				"content": $PanelContainer2/EntornosDeDesarrollo
			}
			]
		},
		{
			"title": "Funciones y procedimientos",
			"subtemas": [
			{
				"title": "Definición de Funciones",
				"content": $PanelContainer2/DefinicionFunciones
			},
			{
				"title": "Alcance de las Variables",
				"content": $PanelContainer2/AlcanceDeLasVariables
			}
			]
		},
		{
			"title": "Búsquedas y Ordenamientos",
			"subtemas": [
			{
				"title": "Vectores y Matrices",
				"content": $PanelContainer2/VectYMat
			},
			{
				"title": "Búsqueda Lineal",
				"content": $PanelContainer2/BusquedaLineal
			},
			{
				"title": "Búsqueda Binaria",
				"content": $PanelContainer2/BusquedaBinaria
			},
			{
				"title": "Ordenamiento por Burbujeo",
				"content": $PanelContainer2/Burbujeo
			},
			]
		},
		{
			"title": "Buenas prácticas",
			"subtemas": [
			{
				"title": "Código Legible y Mantenible",
				"content": $PanelContainer2/CodigoLegible
			},
			]
		}
	]
	for i in range(options.size()):
		var newLabel = labelButton.duplicate()
		newLabel.text = options[i].title
		newLabel.visible = true
		newLabel.pressed.connect(_on_button_2_pressed.bind(i))
		label_container.add_child(newLabel)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_2_pressed(index: int):
	var first = true
	for n in label_subOptions_container.get_children():
		if !first:
			label_subOptions_container.remove_child(n)
			n.queue_free()
		first = false
	for i in range(options[index].subtemas.size()):
		var newLabel = labelSubptionsButton.duplicate()
		newLabel.text = options[index].subtemas[i].title
		newLabel.visible = true
		newLabel.pressed.connect(_on_button_pressed.bind(index, i))
		label_subOptions_container.add_child(newLabel)
		fistScreen.visible = false
		secondScreen.visible = true
		backContainer.visible = true


func _on_button_pressed(i: int, j: int):
	titleButton.visible = false
	title.text = options[i].subtemas[j].title
	content.text = options[i].subtemas[j].content.text#definicionAlgoritmo.text
	fistScreen.visible = false
	secondScreen.visible = false
	thirdScreen.visible = true
	backContainer.visible = true


func _on_back_pressed():
	if secondScreen.visible:
		fistScreen.visible = true
		secondScreen.visible = false
		backContainer.visible = false
	elif thirdScreen.visible:
		thirdScreen.visible = false
		secondScreen.visible = true
		titleButton.visible = true


func _on_close_pressed():
	emit_signal("closeOptions")
