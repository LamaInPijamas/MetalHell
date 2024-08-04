extends CharacterBody2D

@export var move_speed : float = 100

@export var dodge_speed : int = 175

@export var ghost_node : PackedScene

var dodging : bool = false
var can_dodge : bool = true

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var ghost_timer = $ghost_timer
@onready var particles_2d = $GPUParticles2D

var direction : Vector2 = Vector2.ZERO

func _ready():
	animation_tree.active = true
	
func _process(_delta):
	update_animation_parameters()

func _physics_process(_delta):
	direction = Input.get_vector("left", "right", "up", "down").normalized()
	
	if Input.is_action_just_pressed("dodge") and can_dodge:
		if(velocity != Vector2.ZERO):
			dash()
			dodging = true
			can_dodge = false
			animation_tree["parameters/conditions/jett_mode"] = true
			$dodge_time.start()
			$dodge_cooldown.start()
	
	if direction:
		if dodging:
			velocity = direction * dodge_speed
		else:
			velocity = direction * move_speed
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()
	
func add_ghost():
	var ghost = ghost_node.instantiate()
	ghost.set_property(position, $Sprite2D.scale)
	get_tree().current_scene.add_child(ghost)

func dash():
	ghost_timer.start()
	particles_2d.emitting = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", position + velocity, 0.45)
	await tween.finished
	ghost_timer.stop()
	particles_2d.emitting = false
	

func update_animation_parameters():
	if(velocity == Vector2.ZERO):
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true
	
	if(direction != Vector2.ZERO):
		animation_tree["parameters/idle/blend_position"] = direction
		animation_tree["parameters/Run/blend_position"] = direction
		animation_tree["parameters/Dodge/blend_position"] = direction


func _on_dodge_time_timeout():
	dodging = false 
	animation_tree["parameters/conditions/jett_mode"] = false

func _on_dodge_cooldown_timeout():
	can_dodge = true


func _on_ghost_timer_timeout():
	add_ghost()
