extends Sprite2D

@onready var animation_tree : AnimationTree = $AnimationTree

@export var player_node : PackedScene

var direction : Vector2 = Vector2.ZERO

func _process(_delta):
	update_animation_parameters_ghost()

func _physics_process(_delta):
	direction = Input.get_vector("left", "right", "up", "down").normalized()

func _ready():
	ghosting()

func set_property(tx_pos, tx_scale):
	position = tx_pos
	scale = tx_scale
	
#ghosting is a visiual effect that occurs after dodging.
func ghosting():
	var tween_fade = get_tree().create_tween()
	
	tween_fade.tween_property(self, "self_modulate", Color(1, 1, 1, 0),0.75)
	await tween_fade.finished
	
	queue_free()
func update_animation_parameters_ghost():
	if(direction != Vector2.ZERO):
		animation_tree["parameters/Dash/blend_position"] = direction
