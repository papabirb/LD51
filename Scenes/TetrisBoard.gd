extends Node2D

# THIS IS THE TETRIS GRID.
# IT WILL COVER GRID CREATION AND LINE CLEARS.
# ALSO IT WILL BE THE SHAPE FACTORY.

# These are the maximum values for how many colums and rows the grid contains.
# They are exported in order to change the size of the grid without hardcoding.
# The default values are a guess.
export(int) var max_column = 10
export(int) var max_row = 20 # May need to go taller in order to hide shape factories off-screen without overcomplicating the code.

# This is the maximum height and width based on calculations with the reference sprite.
var max_width
var max_height

# This is an array that keeps track of all the "legal spots" in the array.
var columns = []
var rows = []
var min_col = 0 # This is the left-most border of the grid.
var min_row = 0 # This is the top-most border of the grid.

# This is a reference image for calculating the grid "size".
# During prototype, will be the Godot icon. During polish, will be more specific sprite.
# Due to this, a consistent sprite size is recommended during polish.
export(Texture) var ref_sprite

# This is where Shape Factory variables will go.
onready var GamePiece = "res://Scenes/GamePiece.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_columns()
	set_rows()

# These two functions are what set up the known valid positions.
func set_columns():
	max_width = ref_sprite.get_width * max_column
	columns.resize(max_column)
	var i = 0
	while i < max_column:
		columns[i] = (i * ref_sprite.get_width) + position.x #Position.x is used as an offset due to the board possibly not being at (0,0).
		i+=1
	min_col = columns[0]

func set_rows():
	max_height = ref_sprite.get_height * max_row + position.y #In case of not being at (0,0).
	rows.resize(max_row)

# Create a piece at a random location
func block_daddy():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
