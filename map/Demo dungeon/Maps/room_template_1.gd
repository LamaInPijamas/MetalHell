extends Node2D

@onready var hearts_container = $CanvasLayer/hearts_container
@onready var player = $CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	hearts_container.setMaxHearts(player.max_health)
	hearts_container.updateHearts(player.health)
	player.health_change.connect(hearts_container.updateHearts)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
