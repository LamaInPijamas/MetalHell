extends CharacterBody2D

signal health_change 

@export var move_speed : float = 100

@export var dodge_speed : int = 175

@export var max_health : int = 3

@export var knockback_power :int = 2000

@export var inventory: Inventory

var dodging : bool = false
var can_dodge : bool = true

@onready var player_sprite : Sprite2D = $Sprite2D
@onready var attack_animations : AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var effects : AnimationPlayer = $Effects
var last_direction: String = "Down"

var direction : Vector2 = Vector2.ZERO
#eq var
var melee_equiped : bool = false
var melee_attack : bool = false
var can_melee_attack : bool = false

#combat var
var enemy_in_attack_range : bool = false
var enemy_attack_cooldown : bool = true
@onready var health :int  = max_health
var player_alive : bool  = true
var enemyVelocity : Vector2 = Vector2.ZERO

func player():
	pass # just a flag func

func _ready():
	animation_tree.active = true
	effects.play("RESET")
	attack_animations.visible = false
	
func _process(_delta):
	update_animation_parameters()
	enemy_attack()
	
	if health <= 0:
		player_alive = false #add end screen
		health = 0
		self.queue_free()

func _physics_process(_delta):
	direction = Input.get_vector("left", "right", "up", "down").normalized()
	
	var last_direction = "Down"
	if velocity.x < 0: last_direction = "Left"
	elif velocity.x > 0: last_direction = "Right"
	elif velocity.y < 0: last_direction = "Up"
	
	if Input.is_action_just_pressed("dodge") and can_dodge:
		if(velocity != Vector2.ZERO):
			dodging = true
			can_dodge = false
			animation_tree["parameters/conditions/jett_mode"] = true
			$dodge_time.start()
			$dodge_cooldown.start()
				
	if Input.is_action_just_pressed("attack"):
		player_sprite.visible = false
		attack_animations.visible = true
		move_speed = 25
		attack_animations.play("attack" + last_direction)
		Global.current_player_attack = true
		
	if Input.is_action_just_pressed("Ultimate"):
		player_sprite.visible = false
		attack_animations.visible = true
		move_speed = 25
		attack_animations.play("ulti")
		Global.current_player_attack = true
			
	if direction:
		if dodging:
			velocity = direction * dodge_speed
		else:
			velocity = direction * move_speed
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()
	

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

func enemy_attack():
	if enemy_in_attack_range and enemy_attack_cooldown == true:
		enemy_attack_cooldown = false
		$damage_taken_base_cooldown.start()
		health -= 1
		health_change.emit(health)
		knockback(enemyVelocity)
		effects.play("hurt")
		await get_tree().create_timer(1).timeout
		effects.play("RESET")
		
func knockback(enemyVelocity: Vector2):
	var knockback_direction = (enemyVelocity - velocity).normalized() * knockback_power
	velocity = knockback_direction
	move_and_slide()

func _on_dodge_time_timeout():
	dodging = false 
	animation_tree["parameters/conditions/jett_mode"] = false

func _on_dodge_cooldown_timeout():
	can_dodge = true


func _on_melee_attack_time_timeout():
	pass # Replace with function body.


func _on_melee_attack_cooldown_timeout():
	pass # Replace with function body.


func _on_playerhitbox_body_entered(body):
	if body.has_method("enemy"):
		enemyVelocity = body.velocity
		enemy_in_attack_range = true

func _on_playerhitbox_body_exited(body):
	if body.has_method("enemy"):
		enemy_in_attack_range = false


func _on_damage_taken_base_cooldown_timeout():
	enemy_attack_cooldown = true


func _on_playerhitbox_area_entered(area):
	if area.has_method("collect"):
		area.collect(inventory)


func _on_animated_sprite_2d_animation_finished():
	attack_animations.visible = false
	Global.current_player_attack = false
	move_speed = 100
	player_sprite.visible = true
