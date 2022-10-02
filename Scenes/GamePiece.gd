extends Area2D

var children
var id
var block_width = 3 # Most of the shapes are 3 wide, only I and C differ
enum shapes {
	L, J, S, Z, T, I, C
}
var landed = false
signal justLanded
var dragging = false
var mouse_x = 0

# Borrowed variables set at spawn to make dragging function work
var max_width = 0
var max_height = 0
var columns
var rows
var min_col
var min_row
var unit_width
var unit_height

# Positional related for dragging and falling
var left_x
var right_x
var bottom_y

var blockDaddy = null

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	children = get_children()
	shape_factory()
	id = get_instance_id()

func shape_factory():
	var shape = shapes.values()[randi() % shapes.size()]
	match shape:
		shapes.L:
			var i = 0
			while i < 3:
				children[i].position.x += i * children[i].size_w
				children[i].position.y += children[i].size_h
				i+= 1
			children[3].position.x += 2 * children[3].size_w
		shapes.J:
			var i = 1
			while i < children.size():
				children[i].position.x += (i-1) * children[i].size_w
				children[i].position.y += children[i].size_h
				i+= 1
		shapes.S:
			var i = 0
			while i < children.size():
				if i < 2:
					children[i].position.x += (i+1) * children[i].size_w
				else:
					children[i].position.x += (i-2) * children[i].size_w
					children[i].position.y += children[i].size_h
				i += 1
		shapes.Z:
			var i = 0
			while i < children.size():
				if i < 2:
					children[i].position.x += i * children[i].size_w
				else:
					children[i].position.x += (i-1) * children[i].size_w
					children[i].position.y += children[i].size_h
				i += 1
		shapes.T:
			children[0].position.x += children[0].size_w
			var i = 1
			while i < children.size():
				children[i].position.x += (i-1) * children[i].size_w
				children[i].position.y += children[i].size_h
				i+= 1
		shapes.I:
			block_width = 4
			var i = 0
			while i < children.size():
				children[i].position.x += i * children[i].size_w
				i+= 1
		shapes.C:
			block_width = 2
			var i = 0
			while i < children.size():
				if i < 2:
					children[i].position.x += i * children[i].size_w
				else:
					children[i].position.x += (i-2) * children[i].size_w
					children[i].position.y += children[i].size_h
				i += 1

func setup(col, row, min_c, min_r, ref_w, ref_h, father):
	max_width = col[-1]
	max_height = row[-1]
	columns = col
	rows = row
	min_col = min_c
	min_row = min_r
	unit_width = ref_w
	unit_height = ref_h
	blockDaddy = father
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	set_edges()
	if not landed and dragging:
		drag_piece()
	
func set_edges():
	children = get_children()
	var biggest_right_x = 0
	var biggest_bottom_y = 0
	var lowest_x = columns[-1]
	for child in children:
		if child.global_position.x > biggest_right_x:
			biggest_right_x = child.global_position.x
		if child.global_position.x < lowest_x:
			lowest_x = child.global_position.x
		if child.global_position.y > biggest_bottom_y:
			biggest_bottom_y = child.global_position.y
	left_x = lowest_x
	right_x = biggest_right_x
	bottom_y = biggest_bottom_y

func drag_piece():
	var new_space = nearest_column(get_global_mouse_position().x)
	if new_space != mouse_x and new_space != null:
		if check_edges(right_x, position.x, (new_space - mouse_x), max_width + unit_width):
			position.x += (new_space - mouse_x)
			mouse_x = nearest_column(get_global_mouse_position().x)

func check_edges(furthest, closest, distance, max_edge):
	if furthest + distance < max_edge and closest + distance >= 0:
		return true
	return false

func nearest_column(x):
	if x < min_col:
		return min_col
	elif x > columns[-1]:
		return columns[-1]
	else:
		var i = 0
		while i < columns.size():
			if x > columns[i] and x < columns[i+1]:
				return columns[i]
			i += 1

func _on_GamePiece_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("ui_touch"):
		get_tree().set_input_as_handled()
		mouse_x = nearest_column(event.position.x)
		dragging = true

func _input(event):
	if not dragging:
		return
	if event.is_action_released("ui_touch"):
		mouse_x = 0
		dragging = false

func move_down():
	set_edges()
	var nextRow = bottom_y + unit_height
	if nextRow < rows[-1]:
		position.y = global_position.y + unit_height
		if bottom_y == rows[-1]: landed = true

func move_up():
	while get_overlapping_areas().size() > 0:
		position.y = global_position.y - unit_height
	landed = true
	emit_signal("justLanded")


func move_right():
	var new_space = global_position.x + unit_width
	if not landed and check_edges(right_x, position.x, (new_space - global_position.x), max_width + unit_width):
		position.x += (new_space - global_position.x)
		return true
	return false

func move_left():
	var new_space = global_position.x - unit_width
	if not landed and check_edges(right_x, position.x, (new_space - global_position.x), max_width + unit_width):
		position.x += (new_space - global_position.x)
		return true
	return false

func _on_GamePiece_area_entered(area):
	if area.id == id:
		pass
	else:
		blockDaddy.add_overlaps(self, area)
