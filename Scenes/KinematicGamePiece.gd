extends KinematicBody2D

# Modified from https://prosepoetrycode.potterpcs.net/2015/06/2d-grid-movement-with-kinematic-bodies-godot/
var x_accum
var mouse_down
var tile_width
var tile_height
var velocity = Vector2.ZERO
# End tutorial

var mouse_x = 0
var mouse_now = 0

var father
var children

var vertical = false
var horizontal = false

var block_width = 3
var block_height = 2

var cant_drag = false

var floor_impact = false
var landed = false
var never_landed = true

enum shapes {
	L, J, S, Z, T, I, C
}

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	x_accum = 0
	randomize()
	custom_get_children()
	tile_width = children[0].size_w
	tile_height = children[0].size_h
	shape_factory()
	$DropTimer.start()
#	$SlideTimer.start()
	horizontal = true

func custom_get_children():
	children = get_children()
	# remove the timers
	children.pop_back()
	children.pop_back()
	children.pop_back()


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
			block_height = 1
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	horizontal = true
	if Input.is_action_just_released("ui_touch"):
		mouse_down = false
		x_accum = 0
		horizontal = false

	if mouse_down:
		mouse_now = father.nearest_column(get_global_mouse_position().x)
		if mouse_now != null and mouse_x != null:
			x_accum = mouse_now - mouse_x
	else:
		if father.local_col.find(position.x) == -1:
			for i in father.local_col:
				if abs(i - position.x) < tile_width / 2:
					position.x = i
	custom_get_children()
	handle_vertical(delta)
	handle_drag(delta)


func handle_drag(delta):
	if horizontal and never_landed:
		if abs(x_accum) > tile_width:
			velocity.x = tile_width * sign(x_accum)
			x_accum -= tile_width * sign(x_accum)
		else: velocity.x = 0
		move_and_collide(Vector2(x_accum, 0).normalized() * tile_width * 5 * delta)
		horizontal = false

func handle_vertical(delta):
	if vertical:
		if not landed and $BufferTimer.is_stopped():
			if not floor_impact:
				move_and_slide(Vector2(0, tile_height) / delta, Vector2.UP)
				floor_impact = is_on_floor()
			if floor_impact:
				if never_landed: 
					$BufferTimer.start()
					yield($BufferTimer, "timeout")
					land(delta)
				else: land(delta)
		vertical = false

func land(delta):
	landed = move_and_collide(Vector2(0, tile_height), false, true, true) != null
	floor_impact = landed
	if never_landed: never_landed = !landed
	if father.local_row.find(position.y) == -1:
		for i in father.local_row:
			if abs(i - position.y) < 10:
				position.y = i
	if landed:
		father.add_to_grid(children)

func _on_Timer_timeout():
	vertical = true
	$DropTimer.start()


func _on_KinematicGamePiece_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("ui_touch") and not mouse_down:
		mouse_down = event.is_pressed()
		get_tree().set_input_as_handled()
		mouse_x = father.nearest_column(get_global_mouse_position().x)

func _on_SlideTimer_timeout():
	horizontal = never_landed
	$SlideTimer.start()


func _on_BufferTimer_timeout():
	pass
