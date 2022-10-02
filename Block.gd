extends CollisionShape2D

var size_h 
var size_w

# Called when the node enters the scene tree for the first time.
func _ready():
	size_h = $SpritePosition/Sprite.texture.get_height()
	size_w = $SpritePosition/Sprite.texture.get_width()
# Note: Position and size of collision shape must be set before sprite is added.
# If sprite is not 64x64 like godot icon, sprite must be deleted and shape fixed


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
