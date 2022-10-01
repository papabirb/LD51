extends Area2D

var children
var id
enum shapes {
	L, J, S, Z, T, I, C
}
var landed = false
var falling = true

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
			var i = 0
			while i < children.size():
				children[i].position.x += i * children[i].size_w
				i+= 1
		shapes.C:
			var i = 0
			while i < children.size():
				if i < 2:
					children[i].position.x += i * children[i].size_w
				else:
					children[i].position.x += (i-2) * children[i].size_w
					children[i].position.y += children[i].size_h
				i += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
