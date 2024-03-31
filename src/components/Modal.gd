class_name Modal
extends Node2D

#the pressed button, can be secondary or primary.
signal on_primary_pressed()
signal on_secondary_pressed()

#var title = "Titulo"
#var description = "Esta es una description de lo que me esta diciendo este modal ..."
#var title_font_size = 12
#var description_font_size = 9
#var primary_button_label = "Aceptar"
#var secondary_button_label = "Cancelar"


func build (options) : 

	if options.has("title"):
		$Rect/Title.text = options["title"]

	if options.has("description"):
		$Rect/Description.text = options["description"]

	if options.has("primary_button_label"):
		$Rect/PrimaryButton.text = options["primary_button_label"]

	if options.has("secondary_button_label"):
		$Rect/SecondaryButton.text = options["secondary_button_label"]


# 	if options.has("title_font_size"):
#     	$Rect/Title.set("custom_fonts/font/size", options["title_font_size"])

# # Verificar si 'description_font_size' está presente en options y asignar su valor al tamaño de fuente de Description
# if options.has("description_font_size"):
#     $Rect/Description.set("custom_fonts/font/size", options["description_font_size"])
