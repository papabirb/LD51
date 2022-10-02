extends Node2D

var children

var vertical = false
var horizontal = false

var block_width = 3

var cant_drag = false

var landed = false
var never_landed = true

var velocity = Vector2.ZERO

enum shapes {
	L, J, S, Z, T, I, C
}

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	children = $Pieces.get_children()
	for child1 in children:
		child1.connect("movement", self, "drag_motion")
		for child2 in children:
			child1.add_collision_exception_with(child2)
	shape_factory()
	$Timer.start()

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	children = $Pieces.get_children()
	landed = false
	for child in children:
		if child.is_on_floor():
			if child.get_last_slide_collision().collider.is_in_group("Floor"):
				landed = true
				never_landed = false
		
	if vertical:
		if not landed:
			for child in children:
				child.move_and_slide(Vector2(0, child.size_h) / delta, Vector2.UP)
				
		vertical = false
	
	if horizontal:
		var can_move = true
		for child in children:
			if can_move and never_landed:
				child.move_and_slide(velocity, Vector2.UP)
		horizontal = false
		velocity = Vector2.ZERO

func drag_motion(amount):
	velocity = Vector2(amount * 5, 0)
	horizontal = true

func _on_Timer_timeout():
	vertical = true
	$Timer.start()

