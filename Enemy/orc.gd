extends CharacterBody2D

var speed : int = 50
#skibidi check if we are chasing player
var chasing : bool = false
var player = null
var player_in_attack_zone :bool = false 
@export var health : int = 5
var knockback_power :int = 1000
var playerVelo : Vector2 = Vector2.ZERO
var dmg_taking_cooldown : bool = false

func _physics_process(delta):
	
	if health <= 0: 
		health = 0
		speed = 15
		if $AnimatedSprite2D.frame_progress == 1: 
			self.queue_free()
		$AnimatedSprite2D.play("death")
		return
	
	if player_in_attack_zone and Global.current_player_attack:
		if(!dmg_taking_cooldown):
			health -= 1
			print(health)
			speed = 15
			$AnimatedSprite2D.play("hurt")
			dmg_taking_cooldown = true
			$damage_taking_base_cooldown.start()
			
	if $AnimatedSprite2D.animation == "hurt" and $AnimatedSprite2D.frame_progress != 1: return
	if chasing: 
		speed = 50
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

func _on_enemy_hitbox_body_entered(body):
	if body.has_method("player"):
		player_in_attack_zone = true


func _on_enemy_hitbox_body_exited(body):
	if body.has_method("player"):
		player_in_attack_zone = false
		playerVelo = body.velocity
		


func _on_damage_taking_base_cooldown_timeout():
	dmg_taking_cooldown = false
