extends TextureRect

var dragging = false;
var off = Vector2(0,0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var can_drag = true;

func _get_drag_data(at_position):
	if !can_drag: return;
	
	var preview_texture = TextureRect.new();
	
	preview_texture.texture = texture;
	preview_texture.expand_mode = 1;
	preview_texture.size = Vector2(16, 16);
	
	var preview = Control.new();
	preview.add_child(preview_texture);
	print("Hola")
	
	set_drag_preview(preview);
	
	return preview_texture.texture;

func _can_drop_data(at_position, data):
	return data is Texture2D;

func _on_directions_update(new_directions):
	can_drag = false;
