extends Node2D

export(Texture) var ref_sprite
var ref_height
var ref_width
export var grid_width = 10
export var grid_height = 20
var grid = []
var columns = []
var local_col = []
var rows = []
var local_row = []
onready var left_wall = $Wall
onready var right_wall = $Wall2
onready var grid_floor = $Floor
onready var left_extents = $Wall/CollisionShape2D
onready var right_extents = $Wall2/CollisionShape2D
onready var floor_extents = $Floor/CollisionShape2D

var rng = RandomNumberGenerator.new()

const GamePiece = preload("res://Scenes/KinematicGamePiece.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	ref_height = ref_sprite.get_height()
	ref_width = ref_sprite.get_width()
	set_grid()
	block_daddy()
	$Timer.start()

func set_grid():
	columns.resize(grid_width)
	local_col.resize(grid_width)
	rows.resize(grid_height)
	local_row.resize(grid_height)
	var i = 0
	while i < grid_width:
		columns[i] = (i * ref_width) + global_position.x
		local_col[i] = columns[i] - global_position.x
		i += 1
	i = 0
	while i < grid_height:
		rows[i] = (i * ref_height) + global_position.y
		local_row[i] = rows[i] - global_position.y
		i +=1
	for row in grid_height:
		grid.append([])
		for col in grid_width:
			grid[row].append(null)
	
	left_wall.global_position = Vector2(global_position.x - ref_width/2, global_position.y + (ref_height * grid_height / 2))
	left_extents.shape.extents = Vector2(ref_width/2, ref_height * grid_height / 2)
	right_wall.global_position = Vector2(columns[-1] + ref_width * 1.5, global_position.y + (ref_height * grid_height / 2))
	right_extents.shape.extents = left_extents.shape.extents
	grid_floor.global_position = Vector2((columns[0] + columns[-1])/2 + ref_width / 2, rows[-1] + ref_height * 1.5)
	floor_extents.shape.extents = Vector2(columns[-1] / 2, ref_height / 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func block_daddy():
	var blockPiece = GamePiece.instance()
	
	var random_rotation = (randi() % 4)
	var column_choice = rng.randi_range(0, (columns.size()-1) - blockPiece.block_width)
	$Pieces.add_child(blockPiece)
	blockPiece.rotation = deg2rad(90 * random_rotation)
	var offset
	match random_rotation:
		0: offset = 0
		1: offset = blockPiece.block_height
		2: offset = blockPiece.block_width
		3: offset = blockPiece.block_height
	blockPiece.global_position.x = columns[column_choice]
	blockPiece.global_position.x += offset * blockPiece.tile_width
	blockPiece.global_position.y = rows[0]
	blockPiece.father = self
#	blockPiece.connect("just_landed", self, "checkLineClears")

func checkLineClears():
	for row in range(grid_height - 1, -1, -1):
		var count = 0
		print(grid[row])
		for col in range(grid_width -1, -1, -1):
			if grid[row][col] != null: count += 1
		if count == 10:
			for col in grid_width:
				var shape = grid[row][col]
				var parent = shape.get_parent()
				grid[row][col] = null
				shape.queue_free()
				parent.custom_get_children()
				parent.landed = false

func add_to_grid(shapes):
	for shape in shapes:
		var col = columns.find(shape.sprite.global_position.x)
		var row = rows.find(shape.sprite.global_position.y)
		grid[row][col] = shape
	checkLineClears()

func nearest_column(x):
	if x < columns[0]:
		return columns[0]
	elif x > columns[-1]:
		return columns[-1]
	else:
		var i = 0
		while i < columns.size():
			if x > columns[i] and x < columns[i+1]:
				return columns[i]
			i += 1

func nearest_row(y):
	if y < rows[0]:
		return rows[0]
	elif y > rows[-1]:
		return rows[-1]
	else:
		var i = 0
		while i < rows.size():
			if y > rows[i] and y < rows[i+1]:
				return rows[i]
			i += 1

func _on_Timer_timeout():
#	block_daddy()
	$Timer.start()
