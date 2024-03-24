extends StaticBody2D

var dropedBlocks : Array[Node2D]
var initial_drop_position = Vector2(344, 30)

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color(Color.GRAY, 0.4)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	visible = GlobalBlockTracking.is_dragging

func get_drop_position():
	sanitize_nodes()
	var list_size = dropedBlocks.size()
	return Vector2(initial_drop_position.x, initial_drop_position.y + 10*list_size)

func handle_drop(dropped : Node2D):
	insert_node(dropped)

func _on_block_spawn_on_block_deleted(node):
	sanitize_nodes()


func insert_node(new : Node2D):
	var is_in = (dropedBlocks.find(new) != -1)
	if (not is_in):
		dropedBlocks.append(new)
		sanitize_nodes()
	
# Check if all the elements in the node array are still valid.
func sanitize_nodes() :
	dropedBlocks = dropedBlocks.filter(func(x): return is_instance_valid(x))
		
	for child in dropedBlocks:
		child.is_selectable = false;
		
	var last_element = dropedBlocks.back()
	if(last_element):
		last_element.is_selectable = true;
