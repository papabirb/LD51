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
const GamePiece = preload("res://Scenes/GamePiece.tscn")

# RNG stuff
var rng = RandomNumberGenerator.new()

# Handle overlaps
var overlaps = []
var handling_overlaps = false

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	set_columns()
	set_rows()
	$BlockDaddy.start()
	$BlockGravity.start()
	block_daddy()

# These two functions are what set up the known valid positions.
func set_columns():
	max_width = ref_sprite.get_width() * max_column
	columns.resize(max_column)
	var i = 0
	while i < max_column:
		columns[i] = (i * ref_sprite.get_width()) + global_position.x #Global_Position.x is used as an offset due to the board possibly not being at (0,0).
		i+=1
	min_col = columns[0]

func set_rows():
	max_height = ref_sprite.get_height() * max_row + global_position.y #In case of not being at (0,0).
	rows.resize(max_row)
	var i = 0
	while i < max_row:
		rows[i] = (i * ref_sprite.get_height()) + global_position.y
		i += 1
	min_row = rows[0]

# Create a piece at a random location
func block_daddy():
	var blockPiece = GamePiece.instance()
	var column_choice = rng.randi_range(0, (columns.size()-1) - blockPiece.block_width)
	$Pieces.add_child(blockPiece)
	blockPiece.global_position.x = columns[column_choice]
	blockPiece.global_position.y = min_row
	blockPiece.setup(columns, rows, min_col, min_row, ref_sprite.get_width(), ref_sprite.get_height(), self)
	blockPiece.connect("justLanded", self, "checkLineClears")

func checkLineClears():
	pass #For each row in rows, move the Line Clearer; if bodies = max_col, queue_free them, reset all pieces to falling & check their edges and stuff

func add_overlaps(piece1, piece2):
	if overlaps.find(piece1) == -1:
		overlaps.push_back(piece1)
	if overlaps.find(piece2) == -1:
		overlaps.push_back(piece2)

func handle_overlaps():
	if not handling_overlaps:
		var area = overlaps.pop_back()
		if area == null:
			return
		else:
			if area.get_overlapping_areas().size() == 0:
				return
			handling_overlaps = true
			for collision in area.get_overlapping_areas():
				overlaps.pop_at(overlaps.find(collision))
				if not collision.landed and not area.landed:
					if collision.global_position.x >= area.global_position.x:
						print("slide to the right")
						if not collision.move_right(): area.move_left()
					elif collision.global_position.x < area.global_position.x:
						print("slide to the left")
						if not collision.move_left(): area.move_right()
				elif collision.landed:
					if collision.global_position.x >= area.global_position.x:
						if not area.move_left(): area.move_up()
					elif collision.global_position.x < area.global_position.x:
						if not area.move_right(): area.move_up()
				elif area.landed:
					if collision.global_position.x >= area.global_position.x:
						if not collision.move_right(): collision.move_up()
					elif collision.global_position.x < area.global_position.x:
						if not collision.move_left(): collision.move_up()
#				elif collision.global_position.y >= area.global_position.y:
#					print("cha cha real smooth")
#					area.move_up()
#				elif collision.global_position.y < area.global_position.y:
#					collision.move_up()
			handling_overlaps = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_overlaps()


func _on_BlockGravity_timeout():
	for piece in $Pieces.get_children():
		if not piece.landed:
			piece.move_down()
	$BlockGravity.start()


func _on_BlockDaddy_timeout():
	block_daddy()
	block_daddy()
	$BlockDaddy.start()
