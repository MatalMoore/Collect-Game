extends "./Entity.gd"

export(bool) var isCollectable = true

onready var collision = get_node("CollisionShape2D")

func _ready():
	type = "collectible"

func action(arg:String):
	match(arg):
		"collect":
			collect()
		_:
			pass

func collect():
	if(isCollectable):
		#modulate.a *= 0.2
		visible = false
		collision.set_deferred("disabled", true)
