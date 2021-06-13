extends Node2D
class_name Connector

var height = 20
var width = 20
var rect = Rect2(0,0,width,height)
var connector_active = false

enum WireTypes{SQUARE, DIAMOND, CIRCLE}
enum Colors{RED, BLUE, GREEN}
export (WireTypes) var connector_type
export (Colors) var color_name
var sprite

signal connector_clicked
signal connector_released

func get_color():
	return 
	
func get_rect():
	return rect

func _ready():

	add_child(Highlighter.new())
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		if rect.has_point(to_local(event.position)):
			emit_signal("connector_clicked", self)
	if event is InputEventMouseButton and not event.pressed and event.button_index == BUTTON_LEFT:
		if rect.has_point(to_local(event.position)):
			emit_signal("connector_released", self)

func _process(delta):
	update()

func draw_sprite():
	var color
	match color_name:
		Colors.RED:
			color = Color.red
		Colors.BLUE:
			color = Color.blue
		Colors.GREEN:
			color = Color.green
	match connector_type:
		WireTypes.SQUARE:
			var rect = Rect2(Vector2(0,0), Vector2(height,width))
			draw_rect(rect, color)
		WireTypes.CIRCLE:
			var centre = Vector2(height, width)/2
			var radius = height/2
			draw_circle(centre, radius, color)
		WireTypes.DIAMOND:
			draw_set_transform(Vector2(0,0),deg2rad(45),Vector2(1,1))
			var rect = Rect2(Vector2(0,0), Vector2(height,width))
			draw_rect(rect, color)

func _draw():
	draw_sprite()
