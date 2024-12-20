extends Node2D

@onready var tile_map_layer = $TileMapLayer
@onready var player = $CharacterBody2D
@onready var chest_scene = preload("res://Scenes/Chest/chest.tscn")
@onready var orc1_scene = preload("res://Scenes/Enemy/Orc1/orc_1.tscn")
@onready var orc2_scene = preload("res://Scenes/Enemy/Orc2/orc_2.tscn")
@onready var orc3_scene = preload("res://Scenes/Enemy/Orc3/orc_3.tscn")

const WIDTH = 100
const HEIGHT = 80
const CELL_SIZE = 16
const MIN_ROOM_SIZE = 10
const MAX_ROOM_SIZE = 20
const MAX_ROOM = 20

var grid = []
var rooms = []

var wallArray = []
var floorArray = []
var dungeonTileArray = []

var enemyArray = []
var chestArray = []

func _ready():
	randomize()
	initalize_grid()
	generate_dungeon()
	draw_dungeon()
	player.position = Vector2(rooms[0].position.x * CELL_SIZE + 48, rooms[0].position.y * CELL_SIZE + 64)
	spawn_enemies_in_rooms()
	spawn_chests_in_rooms()

func initalize_grid():
	for x in range(WIDTH):
		grid.append([])
		for y in range(HEIGHT):
			grid[x].append(0) # 0 er en tom tile

func generate_dungeon():
	for i in range(MAX_ROOM):
		var room = generate_room()
		if place_room(room):
			if rooms.size() > 0:
				connect_rooms(rooms[-1], room) # Forbinder til forrige room
			rooms.append(room)

func generate_room():
	var width = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE + 1) + MIN_ROOM_SIZE
	var height = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE + 1) + MIN_ROOM_SIZE
	var x = randi() % (WIDTH - width - 1) + 1
	var y = randi() % (HEIGHT - height - 1) + 1
	return Rect2(x, y, width, height)

func place_room(room):
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			if grid[x][y] == 1 || grid[x][y] == 2 : # Gælder hvis tilen allerede er en dungeon tile
				return false
	
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			if (x > room.position.x and x < room.end.x - 1) and (y > room.position.y + 1 and y < room.end.y - 1):
				grid[x][y] = 2  # Floor
			else:
				grid[x][y] = 1  # Wall
	return true

func connect_rooms(room1, room2, corridor_width=5):
	# Vælg startpunkt for room1
	var start = Vector2(
		int(room1.position.x + room1.size.x / 2),
		int(room1.position.y + room1.size.y / 2)
	)
	
	# Vælg slutpunktet fra room2
	var end = Vector2(
		int(room2.position.x + room2.size.x / 2),
		int(room2.position.y + room2.size.y / 2)
	)
	
	var current = start
	
	# Horisontal bevægelse
	while current.x != end.x:
		current.x += 1 if end.x > current.x else -1

		# Korridorens bredde
		var corridor_range = int(corridor_width / 2)
		
		var yi = 0
		for i in range(-corridor_range, corridor_range + 1):
			var xi = 0
			for j in range(-corridor_range-1, corridor_range + 1):
				var grid_x = current.x + i
				var grid_y = current.y + j

				# Tjek grænser
				if range(0, WIDTH+1).find(grid_x) and range(0, HEIGHT+1).find(grid_y) and grid[grid_x][grid_y] != 2:
					# Tjek hvilken tile grid fæltet skal have. 
					# De ydre dele af korridoren er vægge og indre dele er gulv.
					if xi <= 1 || xi == corridor_width || yi == 0 || yi == corridor_width-1:
						grid[grid_x][grid_y] = 1  # Væg
					else:
						grid[grid_x][grid_y] = 2  # Gulv
				xi += 1
			yi += 1
	
	# Vertikal bevægelse
	while current.y != end.y:
		current.y += 1 if end.y > current.y else -1

		# Korridorens bredde
		var corridor_range = int(corridor_width / 2)
		
		var yi = 0
		for i in range(-corridor_range, corridor_range + 1):
			var xi = 0
			for j in range(-corridor_range, corridor_range + 1):
				var grid_x = current.x + i
				var grid_y = current.y + j

				# Tjek grænser
				if range(0, WIDTH+1).find(grid_x) and range(0, HEIGHT+1).find(grid_y) and grid[grid_x][grid_y] != 2:
					# Tjek hvilken tile grid fæltet skal have. 
					# De ydre dele af korridoren er vægge og indre dele er gulv.
					if xi <= 1 || xi == corridor_width-1 || yi == 0 || yi == corridor_width-1:
						grid[grid_x][grid_y] = 1  # Væg
					else:
						grid[grid_x][grid_y] = 2  # Gulv
				xi += 1
			yi += 1

func draw_dungeon():
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var tile_position = Vector2i(x,y)
			if grid[x][y] == 1:
				wallArray.append(tile_position)
				dungeonTileArray.append(tile_position)
				#tile_map_layer.set_cell(tile_position, 1, Vector2i(0,0))
			elif grid[x][y] == 2:
				floorArray.append(tile_position)
				dungeonTileArray.append(tile_position)
				#tile_map_layer.set_cell(tile_position, 1, Vector2i(1, 0))
				
	tile_map_layer.set_cells_terrain_connect(dungeonTileArray, 0, 0, true)
	tile_map_layer.set_cells_terrain_connect(floorArray, 0, 1, true)

func instantiate_enemy(scene, type:String, min_amount:int, max_amount:int, min_room:int, max_room:int):
	for room_number in range(min_room, max_room):
		var room = rooms[room_number]
		for enemy_number in randi_range(min_amount, max_amount):
			var _position
			var tooClose
			var tries = 0
			while tooClose != false or tries >= 10:
				tooClose = false
				_position = get_random_position_in_room(room) * CELL_SIZE
				for enemy in enemyArray:
					if _position.distance_to(enemy.position) < 50:
						tooClose = true
				tries += 1
			
			if tooClose == false:
				var new_enemy = scene.instantiate()
				new_enemy.position = _position
				new_enemy.name = type + "_R" + str(room_number) + "_N" + str(enemy_number)
				add_child(new_enemy)
				enemyArray.append(new_enemy)
				print(new_enemy.name, " ", new_enemy.position)

func spawn_enemies_in_rooms():
	instantiate_enemy(orc3_scene, "orc3", 1, 1, rooms.size()-1, rooms.size())
	instantiate_enemy(orc2_scene, "orc2", 0, 2, 1, rooms.size())
	instantiate_enemy(orc1_scene, "orc1", 1, 3, 1, rooms.size())

func spawn_chests_in_rooms():
	var chest_amount = randi_range(2, 4)
	for chest in range(chest_amount):
		var chest_room = randi_range(0, rooms.size()-1)
		
		var chest_position
		var tooClose
		var tries = 0
		while tooClose != false or tries >= 10:
			tooClose = false
			chest_position = get_random_position_in_room(rooms[chest_room]) * CELL_SIZE
			for _enemy in enemyArray:
				if chest_position.distance_to(_enemy.position) < 50:
					tooClose = true
			for _chest in chestArray:
				if chest_position.distance_to(_chest.position) < 50:
					tooClose = true
			tries += 1
		
		if tooClose == false:
			var new_chest = chest_scene.instantiate()
			new_chest.position = chest_position
			new_chest.name = "chest_R" + str(chest_room) + "_N" + str(chest)
			add_child(new_chest)
			chestArray.append(new_chest)
			print(new_chest.name, " ", new_chest.position)

func get_random_position_in_room(room) -> Vector2:
	var room_min_x = room.position.x +2
	var room_min_y = room.position.y +3
	var room_max_x = room.position.x + room.size.x -2
	var room_max_y = room.position.y + room.size.y -2
	
	var rand_x = randi_range(room_min_x, room_max_x)
	var rand_y = randi_range(room_min_y, room_max_y)

	return Vector2(rand_x,rand_y)
