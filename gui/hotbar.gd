extends Control

var is_open : bool = false

func _ready():
	inventory.updated.connect(update)
	open()
	update()
	
@onready var inventory: Inventory = preload("res://Inventory/playerInventoryRes.tres")
@onready var slots: Array = $GridContainer.get_children()

func update():
	for i in range(min(inventory.items.size(), slots.size())):
		slots[i].update(inventory.items[i])

func open():
	visible = true
	is_open = true
	
func close():
	visible = false
	is_open = false

func _input(event):
	if event.is_action_pressed("hide and show hotbar"):
		if is_open:
			close()
		else:
			open()
