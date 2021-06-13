extends Node2D
class_name Computer

# Classes
var Connector
var Connection
var WireIcon

var hasVirus = false

enum WireTypes{SQUARE, DIAMOND, CIRCLE}
enum CompStates {CLEAN, INFECTED, WIPED, KEY, LOCKED, UNLOCKED, GOAL, LOCKED_WITH_VIRUS,
KEY_WITH_VIRUS}
enum Colors {RED, BLUE, GREEN}

export(Array, WireTypes) var wire_list = []
export(Array, NodePath) var start_links = []
export(Array, WireTypes) var connectors = []

export(bool) var is_start = false
export(CompStates) var start_state = CompStates.CLEAN
export(Colors) var color = Colors.RED

export(PackedScene) var next_level = null

var links = []  # List of other Computer nodes
var state = CompStates.CLEAN

var connector_instances = []
var wire_instances = []

var util_tl
var connector_tl
var display_sprite

#Textures
var diamond_link_texture
var circle_link_texture
var square_link_texture

var virus_texture
var clean_texture
var wiped_texture
var goal_texture
var locked_texture
var locked_with_virus_texture
var key_with_virus_texture
var key_texture
var unlocked_texture

#Audio


# Signals
signal clicked
signal infected
signal goal_reached
signal mouse_released

func load_assets():
	# Loading textures
	diamond_link_texture = preload("res://textures/basic_diamond_icon.png")
	circle_link_texture = preload("res://textures/basic_circle_icon.png")
	square_link_texture = preload("res://textures/basic_square_icon.png")
	virus_texture = preload("res://textures/basic_virus.png")
	clean_texture = preload("res://textures/basic_uninfected.png")
	wiped_texture = preload("res://textures/basic_wiped.png")
	goal_texture = preload("res://textures/basic_goal.png")
	locked_texture = preload("res://textures/basic_lock.png")
	locked_with_virus_texture = preload("res://textures/basic_lock_with_virus.png")
	key_with_virus_texture = preload("res://textures/basic_key_with_virus.png")
	key_texture = preload("res://textures/basic_key.png")
	unlocked_texture = preload("res://textures/basic_unlock.png")
	
	#Scenes
	Connector = preload("res://Connector.tscn")
	Connection = preload("res://Connection.tscn")
	WireIcon = preload("res://WireIcon.tscn")
	
	# Locals
	util_tl = get_node("util_tl")
	connector_tl = get_node("connector_tl")
	display_sprite = get_node("display_sprite")
	
func place_connectors():
	var tl_corner = connector_tl.get_position()
	for connector in connectors:
		var connector_inst = Connector.instance()
		connector_inst.connector_type = connector
		connector_inst.color_name = color
		add_child(connector_inst)
		connector_inst.set_position(tl_corner)
		tl_corner += Vector2(connector_inst.width + 10, 0)
		connector_instances.append(connector_inst)

func _ready():
	load_assets()
	place_connectors()
	for link in start_links:
		links.append(get_node(link))
	state = start_state

# ****************** GAME LOGIC ************************
func get_connector_instances():
	return connector_instances

func set_state(new_state):
	var old_state = state
	self.state = new_state
	if old_state != CompStates.WIPED && new_state == CompStates.INFECTED:
		infect()
	if old_state == CompStates.GOAL:
		emit_signal("goal_reached", next_level)

func infect():
	emit_signal("infected", wire_list) # Picked up by SceneManger and added to inventory
	wire_list = []
	
func link(other, type):
	# Creates a connection to the Other instance of Computer
	other.links.append(self)
	links.append(other)
	var new_connection = Connection.instance()
	new_connection.set_start_comp(self)
	new_connection.set_end_comp(other)
	new_connection.set_type(type)
	new_connection.set_draw_behind_parent(true)
	new_connection.set_z_index(-1)
	add_child(new_connection)
	if other.state == CompStates.LOCKED \
	and self.state == CompStates.KEY_WITH_VIRUS:
		other.state = CompStates.UNLOCKED
	
func unlink(other):
	other.links.erase(self)
	self.links.erase(other)
	if other.state == CompStates.UNLOCKED:
		var is_key_attached = false
		for link in other.links:
			if link.state in [CompStates.KEY, CompStates.KEY_WITH_VIRUS]:
				is_key_attached = true
				break
		if not is_key_attached:
			other.state = CompStates.LOCKED
	
func place_wires():
	for instance in wire_instances:
		instance.queue_free()
	wire_instances = []
	var tl_corner = Vector2(0,0)
	for wire in wire_list:
		var wire_inst = WireIcon.instance()
		wire_inst.wire_type = wire
		util_tl.add_child(wire_inst)
		wire_inst.set_position(tl_corner)
		tl_corner += Vector2(0, wire_inst.height + 4)
		wire_instances.append(wire_inst)


func _process(delta):
	place_wires()
	update()


func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		print_debug(display_sprite.get_rect())
		if display_sprite.get_rect().has_point(display_sprite.to_local(event.position)):
			print_debug("clicked")
			emit_signal("clicked", self)


# ********** Drawing functions ***************
func draw_display():
	match self.state:
		CompStates.CLEAN:
			display_sprite.set_texture(clean_texture)
		CompStates.INFECTED:
			display_sprite.set_texture(virus_texture)
		CompStates.WIPED:
			display_sprite.set_texture(wiped_texture)
		CompStates.GOAL:
			display_sprite.set_texture(goal_texture)
		CompStates.LOCKED_WITH_VIRUS:
			display_sprite.set_texture(locked_with_virus_texture)
		CompStates.KEY:
			display_sprite.set_texture(key_texture)
		CompStates.KEY_WITH_VIRUS:
			display_sprite.set_texture(key_with_virus_texture)
		CompStates.LOCKED:
			display_sprite.set_texture(locked_texture)
		CompStates.UNLOCKED:
			display_sprite.set_texture(unlocked_texture)

func draw_wire_list():
	var tl_corner = util_tl.get_position()
	for wire in wire_list:
		match wire:
			WireTypes.DIAMOND:
				draw_texture(diamond_link_texture, tl_corner)
			WireTypes.CIRCLE:
				draw_texture(circle_link_texture, tl_corner)
			WireTypes.SQUARE:
				draw_texture(square_link_texture, tl_corner)
			
		tl_corner += Vector2(0, diamond_link_texture.get_height()-3)
	update()
		
func debug_draw_sprite_boundary():
	var rect = display_sprite.get_rect()
	draw_rect(rect, Color.greenyellow)
	
func _draw():
	draw_display()


