extends Sprite

export (int) var slide_speed = 1
export (int) var line_spacing = 30

var current_frame = 0

func _ready():
	pass # Replace with function body.

func draw_stripy_background():
	var offset = current_frame%line_spacing
	for ii in range(-600, 50):
		var start_vec = Vector2((ii*line_spacing)+offset, -10)
		var end_vec = start_vec + Vector2(2000,2000)
		draw_line(
			start_vec,
			end_vec,
			Color.dimgray
		)
	current_frame = (current_frame+slide_speed)%line_spacing
	

func _process(delta):
	update()

func _draw():
	draw_stripy_background()
