extends TextureRect

signal movementAdded(texture, slot);
var editable = true;

func _ready():
	GLOBAL.connect("directionsUpdated", _on_directions_update);

func _get_drag_data(at_position):
	if !editable: return;
	
	var preview_texture = TextureRect.new();
	
	preview_texture.texture = texture;
	preview_texture.expand_mode = 1;
	preview_texture.size = Vector2(16, 16);
	
	var preview = Control.new();
	preview.add_child(preview_texture);
	
	set_drag_preview(preview);
	texture = null;	
	
	return preview_texture.texture;

func _can_drop_data(at_position, data):
	return editable && data is Texture2D;

func _drop_data(at_position, data):
	print(editable);
	if !editable: return;
	texture = data;
	emit_signal("movementAdded", texture, self);
	
func _on_directions_update(new_directions):
	editable = false;
