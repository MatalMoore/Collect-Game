extends Node2D

const GridMovement = preload("./GridMovement.gd")
const MyTimer = preload("./MyTimer.gd")

onready var movement:GridMovement = get_parent()
onready var timer:MyTimer = MyTimer.new()

func _ready():
# warning-ignore:return_value_discarded
	movement.connect("direction_changed", self, "on_direction_changed")

func on_direction_changed(direction):
	match(direction):
		GridMovement.Inputs.UP:
			rotation_degrees = 180.0
		GridMovement.Inputs.DOWN:
			rotation_degrees = 0.0
		GridMovement.Inputs.RIGHT:
			rotation_degrees = 270.0
		GridMovement.Inputs.LEFT:
			rotation_degrees = 90.0
		_:
			pass
