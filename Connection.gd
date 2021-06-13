extends Node2D
class_name Connection

enum WireTypes{SQUARE, DIAMOND, CIRCLE}

signal connection_clicked

var start_comp
var end_comp
var start_point
var end_point
var mid_point
var mid_aoi
var wire_type

var height = 10
var width = 10
var offset = 0

var mouse_near = false

var path
var frame
var point_spacing = 20


func set_start_comp(start):
	start_comp = start
	
func set_end_comp(end):
	end_comp = end
	
func get_start_comp():
	return start_comp
	
func get_end_comp():
	return end_comp
	
func set_type(type):
	wire_type = type
	
func get_type():
	return wire_type

func connect_signals():
	var root = get_node("/root/root")
	print(root)
	self.connect("connection_clicked", root, "connection_clicked")

func _ready():
	connect_signals()
	start_point = Vector2(0,0)
	end_point = to_local(end_comp.get_position())
	mid_point = start_point.linear_interpolate(end_point, 0.5) 

func check_mouse_proximity():
	var mouse_pos = get_global_mouse_position()
	if to_local(mouse_pos).distance_to(mid_point) <= 30:
		mouse_near = true
	else:
		mouse_near = false

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		if mouse_near:
			emit_signal("connection_clicked", self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_mouse_proximity()
	update()

func draw_points():
	var dist = start_point.distance_to(end_point)
	var direction_to = start_point.direction_to(end_point)
	var current_point = start_point
	for ii in range(0, dist, dist/point_spacing):
		var pos = start_point.move_toward(end_point, ii+offset)
		draw_point(pos, Color.red)
	offset = (offset + 1)%point_spacing


func draw_point(pos, color):
	match wire_type:
		WireTypes.SQUARE:
			var rect = Rect2(pos, Vector2(height,width))
			draw_rect(rect, color)
		WireTypes.CIRCLE:
			var centre = pos
			var radius = height/2
			draw_circle(centre, radius, color)
		WireTypes.DIAMOND:
			draw_set_transform(pos,deg2rad(45),Vector2(1,1))
			var rect = Rect2(pos, Vector2(height,width))
			draw_rect(rect, color)
			
func draw_highlight():
	draw_circle(mid_point, 10, Color.yellowgreen)
			
func debug_draw():
	draw_circle(end_point, 2, Color.yellow)

func _draw():
	draw_points()
	if mouse_near:
		draw_highlight()
	#debug_draw()
