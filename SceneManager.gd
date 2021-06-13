extends Node2D

enum CompStates {CLEAN, INFECTED, WIPED, KEY, LOCKED, UNLOCKED, GOAL, LOCKED_WITH_VIRUS,
KEY_WITH_VIRUS} # may replace with subclass later
enum WireTypes{SQUARE, DIAMOND, CIRCLE}
enum GameStates {BASE, CONNECTING, TRANSITIONING}

var computers
var current_comp
var dragging_connector = null
var current_dragging_point = null
var connector_range = 320
var connector_pos = null
var game_state = GameStates.BASE
var next_level = null
var transition_counter = 60

var Virus

var inventory = []

var diamond_link_texture
var circle_link_texture
var square_link_texture

var background_beat_sample = preload("res://audio/maybe_beat.wav")
var start_drag_sample = preload("res://audio/question_sound.wav")
var bad_end_drag_sample = preload("res://audio/sad_sound.wav")
var good_end_drag_sample = preload("res://audio/happy_sound.wav")
var move_sample = preload("res://audio/move_sound.wav")
var level_end_sample = preload("res://audio/level_end.wav")

var background_beat_player
var start_drag_player
var bad_end_drag_player
var good_end_drag_player
var move_player
var level_end_player
var break_link_player

signal do_color_twist

func load_resources():
	Virus = load("res://Virus.tscn")
	diamond_link_texture = preload("res://textures/basic_diamond_icon.png")
	circle_link_texture = preload("res://textures/basic_circle_icon.png")
	square_link_texture = preload("res://textures/basic_square_icon.png")
	
	background_beat_player = AudioStreamPlayer.new()
	background_beat_player.set_stream(background_beat_sample)
	add_child(background_beat_player)
	start_drag_player = AudioStreamPlayer.new()
	start_drag_player.set_stream(start_drag_sample)
	add_child(start_drag_player)
	bad_end_drag_player = AudioStreamPlayer.new()
	bad_end_drag_player.set_stream(bad_end_drag_sample)
	add_child(bad_end_drag_player)
	good_end_drag_player = AudioStreamPlayer.new()
	good_end_drag_player.set_stream(good_end_drag_sample)
	add_child(good_end_drag_player)
	move_player = AudioStreamPlayer.new()
	move_player.set_stream(move_sample)
	add_child(move_player)
	level_end_player = AudioStreamPlayer.new()
	level_end_player.set_stream(level_end_sample)
	add_child(level_end_player)
	
	var break_link_sample = preload("res://audio/break_link.wav")
	break_link_player = AudioStreamPlayer.new()
	break_link_player.set_stream(break_link_sample)
	add_child(break_link_player)
	

func get_comps():
	computers = []
	for child in self.get_children():
		print_debug(child.get_name())
		if child.get_name().begins_with("comp"):  # find better way if time
			computers.append(child)

func validate_level():
	current_comp = null
	for comp in computers:
		if comp.is_start:
			if not current_comp:
				current_comp = comp
			else:
				print_debug("Two start points set, level invalid")
	if not current_comp:
		print_debug("Starting computer not set")
	else:
		print_debug("Level valid!")
	
func connect_signals():
	for comp in computers:
		comp.connect("infected", self, "recieve_wires")
		comp.connect("clicked", self, "comp_clicked")
		comp.connect("goal_reached", self, "level_transition")
		for connector in comp.connector_instances:
			connector.connect("connector_clicked", self, "connector_clicked")
			connector.connect("connector_released", self, "connector_released")

func init_level():
	current_comp.set_state(CompStates.INFECTED)
	current_comp.infect()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	load_resources()
	get_comps()
	validate_level()
	connect_signals()
	init_level()


# INPUT
func _input(event):
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == BUTTON_LEFT:
		# Nice sparkles later
		#print_debug("Ping!")
		pass
	if event is InputEventMouseButton \
	and not event.pressed \
	and event.button_index == BUTTON_LEFT:
		end_drag()
		
	if event is InputEventKey \
	and event.scancode == KEY_SPACE \
	and not event.echo:
		emit_signal("do_color_twist")


func recieve_wires(wire_list):
	inventory += wire_list
	print_debug(inventory)


func comp_clicked(comp):
	print_debug(comp.name)
	if comp in current_comp.links:
		move_player.play()
		
		match current_comp.state:
			CompStates.INFECTED:
				current_comp.set_state(CompStates.WIPED)
			CompStates.KEY_WITH_VIRUS:
				current_comp.set_state(CompStates.KEY)
			CompStates.LOCKED_WITH_VIRUS:
				current_comp.set_state(CompStates.LOCKED)
				
		match comp.state:
			CompStates.CLEAN:
				comp.set_state(CompStates.INFECTED)
			CompStates.GOAL:
				comp.set_state(CompStates.INFECTED)
			CompStates.WIPED:
				comp.set_state(CompStates.INFECTED)
			CompStates.KEY:
				comp.set_state(CompStates.KEY_WITH_VIRUS)
			CompStates.LOCKED:
				comp.set_state(CompStates.LOCKED_WITH_VIRUS)
			CompStates.UNLOCKED:
				comp.set_state(CompStates.INFECTED)
				
		current_comp = comp
			


func connector_clicked(connector):
	if connector.connector_type in inventory \
	and connector.get_parent() == current_comp \
	and current_comp.state != CompStates.LOCKED_WITH_VIRUS:
		start_drag(connector)
	else:
		print("No connector of type " + str(connector.connector_type))
		bad_end_drag_player.play()


func connector_released(connector):
	if game_state == GameStates.CONNECTING:
		if connector.connector_type == dragging_connector.connector_type \
		and connector != dragging_connector:
			dragging_connector.get_parent().link(connector.get_parent(), 
			   connector.connector_type)
			inventory.erase(connector.connector_type)
			good_end_drag_player.play()
		else:
			bad_end_drag_player.play()


func connection_clicked(connection):
	if current_comp.state != CompStates.LOCKED_WITH_VIRUS:
		print("unplug")
		connection.get_start_comp().unlink(connection.get_end_comp())
		inventory.append(connection.get_type())
		connection.queue_free()
		break_link_player.play()
	else:
		bad_end_drag_player.play()


func level_transition(next_scene):
	if game_state != GameStates.TRANSITIONING:
		game_state = GameStates.TRANSITIONING
		next_level = next_scene
		emit_signal("do_color_twist")
		level_end_player.play()
	


func start_drag(origin):
	if game_state != GameStates.TRANSITIONING:
		game_state = GameStates.CONNECTING
		dragging_connector = origin
		start_drag_player.play()
		


func update_drag():
	var mouse_pos = get_global_mouse_position()
	var origin_pos = dragging_connector.get_global_position()
	var diff = mouse_pos - origin_pos

	if origin_pos.distance_to(mouse_pos) < connector_range:
		connector_pos = mouse_pos
	else:
		connector_pos = diff.normalized()*connector_range + origin_pos


func end_drag():
	if game_state == GameStates.CONNECTING:
		game_state = GameStates.BASE
		connector_pos = null
		dragging_connector = null

func update_transition():
	transition_counter = transition_counter -1
	if not transition_counter:
		emit_signal("do_color_twist")
		get_tree().change_scene_to(next_level)


func _process(delta):
	if game_state == GameStates.CONNECTING:
		update_drag()
	if game_state == GameStates.TRANSITIONING:
		update_transition()
	update()

#Drawing
func debug_draw_network():
	for computer in computers:
		for link in computer.links:
			draw_line(
				computer.get_global_position(),
				link.get_global_position(),
				Color(255,0,0),2, true)

func draw_inventory():
	var y_off = 10
	for wire in inventory:
		match wire:
			WireTypes.DIAMOND:
				draw_texture(diamond_link_texture, Vector2(10,y_off))
			WireTypes.CIRCLE:
				draw_texture(circle_link_texture, Vector2(10,y_off))
			WireTypes.SQUARE:
				draw_texture(square_link_texture, Vector2(10,y_off))
		y_off += 13

func draw_dragging():
	draw_arc(dragging_connector.get_global_position(), connector_range, 
		0, 2*PI,  24, Color.greenyellow)
	draw_line(dragging_connector.get_global_position(), connector_pos, Color.red, 2.0)

func _draw():
	#debug_draw_network()
	draw_inventory()
	if game_state == GameStates.CONNECTING:
		draw_dragging()
