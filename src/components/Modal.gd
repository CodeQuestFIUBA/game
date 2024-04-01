class_name Modal
extends Node2D

func build_modal (options) : 

	print("buildeando Modal!")
	print(global_position)
	if options.has("title"):
		$Rect/Title.text = options["title"]

	if options.has("description"):
		$Rect/Description.text = options["description"]

	if options.has("primary_button_label"):
		$Rect/BotonPrimario.text = options["primary_button_label"]

	if options.has("secondary_button_label"):
		$Rect/BotonSecundario.text = options["secondary_button_label"]
		
	if options.has("title_font_size"):
		$Rect/Title.set("theme_override_font_sizes/font_size", options["title_font_size"])

	if options.has("description_font_size"):
		$Rect/Description.set("theme_override_font_sizes/font_size", options["description_font_size"])


func _on_boton_primario_mouse_entered():
	GLOBAL.mouse_to_pointer()

func _on_boton_primario_mouse_exited():
	GLOBAL.mouse_to_normal()

func _on_boton_secundario_mouse_entered():
	GLOBAL.mouse_to_pointer()

func _on_boton_secundario_mouse_exited():
	GLOBAL.mouse_to_normal()

func _on_boton_primario_pressed():
	#Global signal,  defined in MODALMANAGER script
	ModalManager.emit_signal("on_modal_primary_pressed")

func _on_boton_secundario_pressed():
	#Global signal,  defined in MODALMANAGER script
	ModalManager.emit_signal("on_modal_secondary_pressed")
