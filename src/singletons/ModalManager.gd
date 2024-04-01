extends Node

@onready var modal_scene = preload("res://components/Modal.tscn")

var modal_instance: Modal

signal on_primary_pressed()
signal on_secondary_pressed()

var default_options = {
	'title': "Titulo",
	'description': "Esta es una description de lo que me esta diciendo este modal ...",
	'title_font_size': 12,
	'description_font_size': 9,
	'primary_button_label': "Aceptar",
	'secondary_button_label': "Cancelar"
}

var current_options = default_options

func open_modal(options = default_options):
	print("abriendo modal!")
	initialize_options(options)
	modal_instance = modal_scene.instantiate()
	add_child(modal_instance)
	modal_instance.build_modal (current_options)

func close_modal ():
	if is_instance_valid(modal_instance) :
		modal_instance.queue_free()

func initialize_options(options = null):
	if options == null:
		return
	current_options = options
	for option in default_options:
		if !current_options.has(option):
			current_options[option] = default_options[option]
