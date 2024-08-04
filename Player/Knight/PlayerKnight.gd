extends CharacterBody2D

@export var move_speed : float = 100

func _physics_process(_delta):
	var input_direction = Vector2(
		Input.get_action_raw_strength("right") - Input.get_action_raw_strength("left"),
		Input.get_action_raw_strength("down") - Input.get_action_raw_strength("up")
	)
	
	velocity = input_direction * move_speed
	
	move_and_slide()
