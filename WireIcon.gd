extends Node2D
class_name WireIcon

enum WireTypes{SQUARE, DIAMOND, CIRCLE}

var diamond_link_texture = preload("res://textures/basic_diamond_icon.png")
var circle_link_texture = preload("res://textures/basic_circle_icon.png")
var square_link_texture = preload("res://textures/basic_square_icon.png")
var wire_type = WireTypes.SQUARE
var sprite
var width
var height

func _ready():
	sprite = Sprite.new()
	add_child(sprite)
	match wire_type:
		WireTypes.SQUARE:
			sprite.set_texture(square_link_texture)
		WireTypes.DIAMOND:
			sprite.set_texture(diamond_link_texture)
		WireTypes.CIRCLE:
			sprite.set_texture(circle_link_texture)
	width = sprite.get_rect().size.x
	height = sprite.get_rect().size.y


func _process(delta):
	match wire_type:
		WireTypes.SQUARE:
			sprite.set_texture(square_link_texture)
		WireTypes.DIAMOND:
			sprite.set_texture(diamond_link_texture)
		WireTypes.CIRCLE:
			sprite.set_texture(circle_link_texture)
	width = sprite.get_rect().size.x
	height = sprite.get_rect().size.y
