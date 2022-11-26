extends "./GridMovementInput.gd"

func _ready():
	type = "player"

func action(arg:String):
	match(arg):
		"hit":
			hit()
		_:
			pass

func hit():
	queue_free()
