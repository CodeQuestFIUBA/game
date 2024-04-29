extends Node2D


@onready var player = $Player
@onready var base_sprite = $Sprite2D
@onready var master = $Master
@onready var tileMapDoor = $TileMap2

enum {
	VEGETABLE,
	MEAT,
	FISH
}

var total_items = {
	"fish": {
		"items": 5,
		"variants": {
			"octupus": 2,
			"shirmp": 1,
			"calamari": 1,
			"fish": 1
		}
	},
	"vegetables": {
		"items": 4,
		"variants": {
			"seed1": 2,
			"seed2": 1,
			"seedLarge": 1
		}
	},
	"meat": {
		"items": 3,
		"variants": {
			"beaf": 2,
			"yakitori": 1
		}
	}
}

var fish_textures_index = 0
var fish_textures = [
	{
		"texture": "res://sprites/food/Calamari.png",
		"pos": Vector2(104,40)
	},
	{
		"texture": "res://sprites/food/Octopus.png",
		"pos": Vector2(136,40)
	},
	{
		"texture": "res://sprites/food/Octopus.png",
		"pos": Vector2(120,56)
	},
	{
		"texture": "res://sprites/food/Fish.png",
		"pos": Vector2(104,72)
	},
	{
		"texture": "res://sprites/food/Shrimp.png",
		"pos": Vector2(136,72)
	}
]

var vegetables_textures_index = 0
var vegetables_textures = [
	{
		"texture": "res://sprites/food/SeedBig1.png",
		"pos": Vector2(216,40)
	},
	{
		"texture": "res://sprites/food/SeedLarge.png",
		"pos": Vector2(200,56)
	},
	{
		"texture": "res://sprites/food/SeedBig2.png",
		"pos": Vector2(232,56)
	},
	{
		"texture": "res://sprites/food/SeedBig1.png",
		"pos": Vector2(216,72)
	}
]
var meat_textures_index = 0;
var meat_textures = [
	{
		"texture": "res://sprites/food/Beaf.png",
		"pos": Vector2(312,56)
	},
	{
		"texture": "res://sprites/food/Beaf.png",
		"pos": Vector2(296,72)
	},
	{
		"texture": "res://sprites/food/Yakitori.png",
		"pos": Vector2(328,72)
	},
]

var table_sprite = "res://sprites/table2.png"
var end = false
var texture = null
var selected_type = null
var box1_type = null
var box2_type = null
var box3_type = null


# Called when the node enters the scene tree for the first time.
func _ready():
	var phrases: Array[String] = [
		"Bienvenido, es hora de aprender los principios de la programación", 
		"Tenemos tres mesas con diferentes tipos de alimentos",
		"En la primera tenemos pescados",
		"En la segunda vegetales",
		"Y en la tercera carnes",
		"Y por abajo tenemos tres contenedores, para guardar cada tipo diferente de alimentos.",
		"Necesitamos que guardes los alimentos de la mesa en cada contenedor",
		"Pero dado que los aldeanos necesitan que no se mezclen los alimentos",
		"Se debe guardar en cada contenedor un tipo de alimento distinto."
	]
	await show_master_messages(phrases)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _get_texture_by_type():
	pass

func _on_first_table_body_entered(body):
	if texture || fish_textures_index >= fish_textures.size():
		return
	texture = fish_textures[fish_textures_index]["texture"]
	player.set_object_texture(texture)
	player.set_show_object(true)
	selected_type = FISH
	cover_table(fish_textures[fish_textures_index]["pos"])
	fish_textures_index += 1


func _on_second_table_body_entered(body):
	if texture || vegetables_textures_index >= vegetables_textures.size():
		return
	texture = vegetables_textures[vegetables_textures_index]["texture"]
	player.set_object_texture(texture)
	player.set_show_object(true) 
	selected_type = VEGETABLE
	cover_table(vegetables_textures[vegetables_textures_index]["pos"])
	vegetables_textures_index += 1


func _on_third_table_body_entered(body):
	if texture || meat_textures_index >= meat_textures.size():
		return
	texture = meat_textures[meat_textures_index]["texture"]
	player.set_object_texture(texture)
	player.set_show_object(true) 
	selected_type = MEAT
	cover_table(meat_textures[meat_textures_index]["pos"])
	meat_textures_index += 1


func cover_table(position: Vector2):
	var sprite = Sprite2D.new()
	sprite.position = Vector2(position)
	sprite.z_index = 6
	sprite.texture = ResourceLoader.load(table_sprite)
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
		var phrases: Array[String] = ["Cada caja debe tener un tipo de alimentos"]
		show_master_messages(phrases)
	if exist_box_with_element:
		var phrases: Array[String] = ["Ya existe una caja con ese  tipo de alimentos"]
		show_master_messages(phrases)
	return invalid_box_type || exist_box_with_element


func _on_box_1_body_entered(body):
	if invalidate_add_element(box1_type):
		return
	box1_type = selected_type
	var x: int = randi_range(176,192)
	var y: int = randi_range(176,192)
	add_sprite(x,y)


func _on_box_2_body_entered(body):
	if invalidate_add_element(box2_type):
		return
	box2_type = selected_type
	var x: int = randi_range(256,272)
	var y: int = randi_range(176,192)
	add_sprite(x,y)


func _on_box_3_body_entered(body):
	if invalidate_add_element(box3_type):
		return
	box3_type = selected_type
	var x: int = randi_range(336,352)
	var y: int = randi_range(176,192)
	add_sprite(x,y)


func show_master_messages(phrases: Array[String]):
	master.update_phrases(phrases, Vector2(48,176), true, {'auto_play_time': 1, 'close_by_signal': true})
	await DialogManager.signalCloseDialog


func end_game():
	if end || meat_textures.size() > meat_textures_index || vegetables_textures.size() > vegetables_textures_index || fish_textures.size() > fish_textures_index:
		return
	end = true
	var phrases: Array[String] = [
		"Felicitaciones, completaste el desafio", 
		"Ahora tendria que hacer una introduccion a como se relaciona esto con una variable",
		"Pero queda para cuando lo tenga mas claro...",
		"Puedes retirarte para seguir con los proximos desafios..."
	]
	await show_master_messages(phrases)
	tileMapDoor.queue_free()
