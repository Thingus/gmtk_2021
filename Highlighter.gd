extends Node2D
class_name Highlighter

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rect
var aoi
var mouse_near = false

# Called when the node enters the scene tree for the first time.
func _ready():
	rect = get_parent().get_rect().grow(5)
	aoi = rect.grow(10)

func check_mouse_proximity():
	var mouse_pos = get_global_mouse_position()
	if aoi.has_point(to_local(mouse_pos)):
		mouse_near = true
	else:
		mouse_near = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_mouse_proximity()
	update()
	
func _draw():
	if mouse_near:
		draw_rect(rect, Color.greenyellow, false)
