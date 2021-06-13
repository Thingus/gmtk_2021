extends Node2D


var twister_shader = preload("res://textures/rainbow.shader")
var twister_material
var twisting = false
# Called when the node enters the scene tree for the first time.
func _ready():
	var root = get_node("/root/root")
	twister_material = ShaderMaterial.new()
	twister_material.set_shader(twister_shader)
	root.connect("do_color_twist", self, "flip_color_twist")

func flip_color_twist():
	if not twisting:
		self.get_parent().set_material(twister_material)
		twisting = true
	else:
		self.get_parent().set_material(null)
		twisting = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
