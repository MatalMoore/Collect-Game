extends "./Entity.gd"

onready var area = get_node("Area2D")
onready var collision = get_node("CollisionShape2D")

func _ready():
	type = "door"

func action(arg:String):
	match(arg):
		"open":
			open()
		_:
			pass

func open():
	visible = false
	collision.set_deferred("disabled", true)
