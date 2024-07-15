extends Node2D

@onready var languageButton = $LanguageButton

func _ready():
	languageButton.add_item("Español")
	languageButton.add_item("English")

func _on_player_detector_body_entered(body: Node2D) -> void:
	RoomEvents.room_entered.emit(self)

func _on_sound_check_box_toggled(toggled_on):
	if(toggled_on) :
		BackgroundMusic.enable()
	else : 
		BackgroundMusic.disable()


func _on_language_button_item_selected(index):
	print(index);
	if (index == 1):
		change_to_english()
	if(index == 0):
		change_to_spanish()
	
	
func change_to_spanish():
	$Settings.text = "CONFIGURACIÓN"
	$Sonido.text = "Sonido";
	$Lenguaje.text = "Lenguaje"
	
func change_to_english():
	$Settings.text = "SETTINGS"
	$Sonido.text = "Sound";
	$Lenguaje.text = "Language";
	
