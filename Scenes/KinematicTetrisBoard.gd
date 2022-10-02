extends Node2D

export(Texture) var ref_sprite
var ref_height
var ref_width
export var grid_width = 10
export var grid_height = 20
var columns = []
var rows = []
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
	rows.resize(grid_height)
	var i = 0
	while i < grid_width:
		columns[i] = (i * ref_width) + global_position.x
		i += 1
	i = 0
	while i < grid_height:
		rows[i] = (i * ref_height) + global_position.y
		i +=1
	left_wall.global_position = Vector2(global_position.x - ref_width/2, global_position.y + (ref_height * grid_height / 2))
	left_extents.shape.extents = Vector2(ref_width/2, ref_height * grid_height / 2)
	right_wall.global_position = Vector2(columns[-1] + ref_width * 1.5, global_position.y + (ref_height * grid_height / 2))
	right_extents.shape.extents = left_extents.shape.extents
	grid_floor.global_position = Vector2((columns[0] + columns[-1])/2 + ref_width / 2, rows[-1] + ref_height/2)
	floor_extents.shape.extents = Vector2(columns[-1] / 2, ref_height / 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func block_daddy():
	var blockPiece = GamePiece.instance()
	var column_choice = rng.randi_range(0, (columns.size()-1) - blockPiece.block_width)
	$Pieces.add_child(blockPiece)
	blockPiece.global_position.x = columns[column_choice]
	blockPiece.global_position.y = rows[0]
#	blockPiece.connect("just_landed", self, "checkLineClears")

func checkLineClears():
	pass

func _on_Timer_timeout():
	block_daddy()
	$Timer.start()
