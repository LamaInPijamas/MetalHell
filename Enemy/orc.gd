extends CharacterBody2D

var speed : int = 50
#skibidi check if we are chasing player
var chasing : bool = false
var player = null

func _physics_process(delta):
	
	if chasing: 
		position += (player.position - position) / speed
		
		$AnimatedSprite2D.play("walk")
		
		if(player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("idle")
		
	move_and_collide(Vector2(0,0))

func _on_area_2d_body_entered(body):
	player = body
	chasing = true


func _on_area_2d_body_exited(body):
	player = null
	chasing = false
	
func enemy():
	pass # just a flag

