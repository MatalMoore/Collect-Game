extends "./GridMovement.gd"

signal collided_Entity(entityMoving, entityColliding)
signal input_direction(direction)

export(int) var moveTiles = 1

var inputVector:Vector2 = Vector2.ZERO
var newestInputDirection:String = ""
var inputDirection:String = ""

func _ready():	
# warning-ignore:return_value_discarded
	connect("area_entered", self, "collided_Entity")
	set_process(true)

func _input(event):
	if(newestInputDirection != ""):
		for direction in Inputs.LIST:
			if(direction == newestInputDirection && event.is_action_released(direction)):
				newestInputDirection = ""
				emit_signal("input_direction", newestInputDirection)
				break
	
	for direction in Inputs.LIST:
		if(event.is_action_pressed(direction)):
			newestInputDirection = direction
			emit_signal("input_direction", newestInputDirection)
			break

func _process(_float):
	inputDirection = calculateInput()
	if(inputDirection != ""):
		set_process(false)
		if(isMoveValid(inputDirection)):
			if(moveStep(inputDirection, moveTiles, moveDelayTile) != null):
				yield(self, "step_completed")
		if(!isMoving):
			set_process(true)

func collided_Entity(area):
	emit_signal("collided_Entity", self, area)

func calculateInput() -> String:
	if(newestInputDirection != ""
	&& isMoveValid(newestInputDirection)
	&& !Input.is_action_pressed(getOppositeDirection(newestInputDirection))
	):
		return newestInputDirection
	else:
		inputVector = Vector2.ZERO
	
		if(Input.is_action_pressed(Inputs.UP) && isMoveValid(Inputs.UP)):
			inputVector.y += 1.0
		if(Input.is_action_pressed(Inputs.DOWN) && isMoveValid(Inputs.DOWN)):
			inputVector.y += -1.0
		if(Input.is_action_pressed(Inputs.RIGHT) && isMoveValid(Inputs.RIGHT)):
			inputVector.x += 1.0
		if(Input.is_action_pressed(Inputs.LEFT) && isMoveValid(Inputs.LEFT)):
			inputVector.x += -1.0
		
		match(inputVector.x):
			1.0: return Inputs.RIGHT
			-1.0: return Inputs.LEFT
		match(inputVector.y):
			1.0: return Inputs.UP
			-1.0: return Inputs.DOWN
		
		return ""

func resetInput():
	newestInputDirection = ""
