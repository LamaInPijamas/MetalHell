extends Node2D

@export var Room = preload("res://map/room.tscn")
@onready var Map = $TileMap

var tile_size = 16 
var number_of_rooms = 16
# Minimum/maximum [amount of tiles that the room can be.]
var min_size = 4
var max_size = 12
var hspread = 150
var cull = 0.5

var path # AStar2D pathfinding object

func _ready():
	randomize()
	create_rooms()

func create_rooms():
	for i in range(number_of_rooms):
		var pos = Vector2(randf_range(-hspread, hspread), 0)
		var r = Room.instantiate()
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		r.create_room(pos, Vector2(w, h) * tile_size)
		$Rooms.add_child(r)
	
	# Wait for movement to stop
	await get_tree().create_timer(1.5).timeout
	
	# Collect valid room positions
	var room_positions = []
	for room in $Rooms.get_children():
		if randf() < cull:
			room.queue_free()
		else:
			room.freeze = true
			# Convert 2D position to a format usable by AStar2D
			room_positions.append(Vector2(room.position.x, room.position.y))
	
	await get_tree().create_timer(0.5).timeout
	
	# Find and connect minimum spanning tree (MST) paths
	path = find_mst(room_positions)

	# Request drawing update
	queue_redraw()

func find_mst(nodes):
	var path = AStar2D.new()
	
	# Initialize the path with the first node
	var first_id = path.get_available_point_id()
	path.add_point(first_id, nodes.pop_front())
	
	# Repeat until all nodes are added to the path
	while nodes:
		var min_dist = INF # Minimum distance
		var min_p = null # Closest position to add
		var p_id = -1 # ID of the closest point in the path
		
		# Loop through points in the path
		for p1_id in path.get_point_ids():
			var p1 = path.get_point_position(p1_id)
			
			# Loop through the remaining nodes
			for p2 in nodes:
				var dist = p1.distance_to(p2)
				if dist < min_dist:
					min_dist = dist
					min_p = p2
					p_id = p1_id
		
		if min_p != null and p_id != -1:
			var new_id = path.get_available_point_id()
			path.add_point(new_id, min_p)
			path.connect_points(p_id, new_id)
			nodes.erase(min_p)
	
	return path

func _draw():
	# Draw the lines connecting the MST
	if path:
		for p1_id in path.get_point_ids():
			var p1 = path.get_point_position(p1_id)
			for p2_id in path.get_point_connections(p1_id):
				var p2 = path.get_point_position(p2_id)
				draw_line(p1, p2, Color(0, 1, 0), 2)  # Green lines with width 2
func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		make_map()

func make_map():
	# Clear the tile map
	Map.clear()
	
	# Initialize full_rect to encompass all rooms
	var full_rect = Rect2()

	# Calculate the bounding rectangle for all rooms
	for room in $Rooms.get_children():
		var room_position = room.position
		var room_size = room.get_node("CollisionShape2D").shape.extents * 2
		var r = Rect2(room_position - room_size / 2, room_size)
		full_rect = full_rect.merge(r)
	
	# Convert the viewport size to integers for tile placement
	var topleft = Vector2i(0, 0)
	var bottomright = Vector2i(get_viewport().size / 16)
	
	# Fill the tile map with void initially, then mark walkable areas
	for x in range(topleft.x, bottomright.x):
		for y in range(topleft.y, bottomright.y):
			Map.set_cell(x, y, 0)  # Set all cells to void (tile index 0)

	# Set walkable tiles within the bounding rectangle of rooms
	for x in range(int(full_rect.position.x / Map.cell_size.x), int((full_rect.position.x + full_rect.size.x) / Map.cell_size.x)):
		for y in range(int(full_rect.position.y / Map.cell_size.y), int((full_rect.position.y + full_rect.size.y) / Map.cell_size.y)):
			Map.set_cell(x, y, 12)  # Set walkable area to tile index 12
