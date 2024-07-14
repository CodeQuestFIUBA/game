extends Node2D


@onready var player = $Player
@onready var base_sprite = $Sprite2D
@onready var master = $Master


var box_1_textures_index = 0
var box_1_textures = [
	{
		"texture": "res://sprites/objects/WaterPot.png",
		"pos": Vector2(168,168),
		"type": "potion"
	},
	{
		"texture": "res://sprites/weapons/Katana.png",
		"pos": Vector2(184,168),
		"type": "weapon"
	},
	{
		"texture": "res://sprites/food/SeedBig1.png",
		"pos": Vector2(184,184),
		"type": "meal"
	}
]

var box_2_textures_index = 0
var box_2_textures = [
	{
		"texture": "res://sprites/food/SeedLarge.png",
		"pos": Vector2(264,184),
		"type": "meal"
	},
	{
		"texture": "res://sprites/weapons/Sai.png",
		"pos": Vector2(248,184),
		"type": "weapon"
	},
	{
		"texture": "res://sprites/objects/MilkPot.png",
		"pos": Vector2(248,168),
		"type": "potion"
	}
]
var box_3_textures_index = 0;
var box_3_textures = [
	
	{
		"texture": "res://sprites/objects/LifePot.png",
		"pos": Vector2(344,168),
		"type": "potion"
	},
	{
		"texture": "res://sprites/weapons/Katana.png",
		"pos": Vector2(344,184),
		"type": "weapon"
	},
	{
		"texture": "res://sprites/food/Beaf.png",
		"pos": Vector2(328,168),
		"type": "meal"
	}
]

var ground_sprite = "res://sprites/ground.png"
var end = false
var texture = null
var selected_type = null
var box1_type = null
var box2_type = null
var box3_type = null



func _ready():
	var phrases: Array[String] = [
		"Bienvenido, es hora de aprender los principios de la programación", 
		"Tenemos tres cajas con diferentes tipos de objetos",
		"Y por arriba tenemos tres mesas, para separar cada tipo de objeto diferente.",
		"Necesitamos que organices los objetos de la cajas en cada mesa por tipo",
		"Aso es más facil hallarlos en el equipaje.",
	]
	show_master_messages(phrases)


func _process(delta):
	pass


func _get_texture_by_type():
	pass

func _on_first_table_body_entered(body):
	if texture || box_1_textures_index >= box_1_textures.size():
		return
	texture = box_1_textures[box_1_textures_index]["texture"]
	player.set_object_texture(texture)
	player.set_show_object(true)
	selected_type = box_1_textures[box_1_textures_index]["type"]
	cover_table(box_1_textures[box_1_textures_index]["pos"])
	box_1_textures_index += 1


func _on_second_table_body_entered(body):
	if texture || box_2_textures_index >= box_2_textures.size():
		return
	texture = box_2_textures[box_2_textures_index]["texture"]
	player.set_object_texture(texture)
	player.set_show_object(true) 
	selected_type = box_2_textures[box_2_textures_index]["type"]
	cover_table(box_2_textures[box_2_textures_index]["pos"])
	box_2_textures_index += 1


func _on_third_table_body_entered(body):
	if texture || box_3_textures_index >= box_3_textures.size():
		return
	texture = box_3_textures[box_3_textures_index]["texture"]
	player.set_object_texture(texture)
	player.set_show_object(true) 
	selected_type = box_3_textures[box_3_textures_index]["type"]
	cover_table(box_3_textures[box_3_textures_index]["pos"])
	box_3_textures_index += 1


func cover_table(position: Vector2):
	var sprite = Sprite2D.new()
	sprite.position = Vector2(position)
	sprite.z_index = 6
	sprite.texture = ResourceLoader.load(ground_sprite)
	add_child(sprite)


func add_sprite(x: int, y: int):
	if texture == null:
		return
	var sprite = Sprite2D.new()
	sprite.position = Vector2(x,y)
	sprite.z_index = 3
	sprite.texture = ResourceLoader.load(texture)
	player.set_show_object(false) 
	add_child(sprite)
	texture = null
	selected_type = null
	end_game()


func invalidate_add_element(box_type):
	if texture == null || selected_type == null:
		return false
	var invalid_box_type = box_type != null && box_type != selected_type
	var exist_box_with_element = box_type == null && (box1_type == selected_type || box2_type == selected_type || box3_type == selected_type)
	if invalid_box_type:
		var phrases: Array[String] = ["Cada mesa debe tener un tipo de objeto"]
		show_master_messages(phrases)
	if exist_box_with_element:
		var phrases: Array[String] = ["Ya existe una mesa con ese tipo de objetos"]
		show_master_messages(phrases)
	return invalid_box_type || exist_box_with_element


func _on_box_1_body_entered(body):
	if invalidate_add_element(box1_type):
		return
	box1_type = selected_type
	var x: int = randi_range(104,136)
	var y: int = randi_range(40,72)
	add_sprite(x,y)


func _on_box_2_body_entered(body):
	if invalidate_add_element(box2_type):
		return
	box2_type = selected_type
	var x: int = randi_range(200,232)
	var y: int = randi_range(40,72)
	add_sprite(x,y)


func _on_box_3_body_entered(body):
	if invalidate_add_element(box3_type):
		return
	box3_type = selected_type
	var x: int = randi_range(296,328)
	var y: int = randi_range(40,72)
	add_sprite(x,y)


func show_master_messages(phrases: Array[String]):
	master.update_phrases(phrases, Vector2(48,176), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog


func end_game():
	if end || box_3_textures.size() > box_3_textures_index || box_2_textures.size() > box_2_textures_index || box_1_textures.size() > box_1_textures_index:
		return
	end = true
	var phrases: Array[String] = [
		"¡Felicidades! Has organizado los objetos en las mesas.", 
		"Cada mesa representa una variable en programación, guardando un tipo específico de objeto.",
		"Así como organizaste los objetos, las variables nos ayudan a organizar y almacenar datos.",
		"Recuerda, una variable es como una mesa donde guardas cosas específicas para usarlas fácilmente."
	]
	await show_master_messages(phrases)
