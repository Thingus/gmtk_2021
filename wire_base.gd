extends Sprite


enum types{SQUARE, DIAMOND, CIRCLE}
export (types) var type
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw(Vector2 tl_corner)
	draw_texture()

