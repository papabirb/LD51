extends CollisionShape2D

onready var sprite = $Sprite
var sprite_width
var sprite_height
var size_w
var size_h

var start_point = null

signal movement(horizontal)

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_width = sprite.texture.get_width()
	sprite_height = sprite.texture.get_height()
	size_w = sprite_width
	size_h = sprite_width
	shape.extents = Vector2((size_w / 2) - 1, (size_h / 2) - 1)
	position = Vector2(size_w / 2, size_h / 2)
	sprite.position = Vector2(-position.x, -position.y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
