extends KinematicBody2D

# Modified from https://prosepoetrycode.potterpcs.net/2015/06/2d-grid-movement-with-kinematic-bodies-godot/
var x_accum

var mouse_down

var sprite_width
var sprite_height
var size_w
var size_h

var start_point = null

signal movement(horizontal)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	x_accum = 0
	sprite_width = $Sprite.texture.get_width()
	sprite_height = $Sprite.texture.get_height()
	size_w = sprite_width
	size_h = sprite_width
	$CollisionShape2D.shape.extents = Vector2((size_w / 2), (size_h / 2))
	$CollisionShape2D.position = Vector2(size_w / 2, size_h / 2)
	mouse_down = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mouse_down:
		x_accum = get_global_mouse_position().x - start_point
		if abs(x_accum) > sprite_width:
			emit_signal("movement", sprite_width * sign(x_accum))
			x_accum -= sprite_width * sign(x_accum)
	
	if not mouse_down:
		x_accum = 0
		start_point = null

func _input(event):
	if event.is_action_released("ui_touch"):
		mouse_down = false

func _on_KinematicBlock_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("ui_touch"):
		start_point = get_global_mouse_position().x
		mouse_down = true
