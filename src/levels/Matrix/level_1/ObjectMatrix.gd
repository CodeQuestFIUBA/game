extends TileMap
var offsetX = 4;
var offsetY = 5;
var x = offsetX;
var y = offsetY;

var gridHeight = 6;
var gridWidth = 10;
var markerLayer = 6;
var markerTextureCoord = Vector2i(6, 1);
var markerTextureAlt = 2;

func _ready():
	updateMarker(Vector2i(offsetX, offsetY), Vector2i(-1, -1))
			
func updateMarker(coords, previousCoords):
	erase_cell(markerLayer, previousCoords);
	set_cell(markerLayer, coords, 1, markerTextureCoord, markerTextureAlt);

func _on_timer_timeout():
	var prevX = x;
	var prevY = y;
	if (y >= gridHeight + offsetY): return;
	if (x < gridWidth + offsetX - 1):
		prevX = x;
		x+=1;
	else: 
		prevX = x;
		prevY = y;
		x = offsetX;
		y += 1;
	updateMarker(Vector2i(x, y), Vector2i(prevX, prevY));
