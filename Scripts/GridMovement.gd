extends "./Entity.gd"

const Inputs = preload("./Inputs.gd")
const MyTimer = preload("./MyTimer.gd")

signal move_completed
signal step_completed
signal path_completed
signal direction_changed(direction)

enum PathTypes{
	default,
	opposite,
	inverted
}
var PathKeys:Dictionary = {
	"default": PathTypes.default,
	"opposite": PathTypes.opposite,
	"inverted": PathTypes.inverted
}

export(float) var tileSize = 64.0 setget set_tileSize
export(float) var moveTimeTile = 0.5
export(float) var moveDelayTile = 0.0
export(float) var moveDelayStep = 0.0

var movementVectors:Dictionary

var timer:MyTimer
var collisionRay:RayCast2D
var movingTween:Tween

var directionCurrent:String = Inputs.DOWN

onready var isMoving = false

var _pathSize:int

func _ready():
	set_movementVectors(tileSize)
	
	timer = MyTimer.new()
	collisionRay = RayCast2D.new()
	movingTween = Tween.new()
	
	add_child(timer)
	add_child(collisionRay)
	add_child(movingTween)

func set_tileSize(size:float):
	tileSize = size
	set_movementVectors(size)

func set_movementVectors(size:float):
	movementVectors = {
		Inputs.UP: Vector2.UP * size,
		Inputs.DOWN: Vector2.DOWN * size,
		Inputs.LEFT: Vector2.LEFT * size,
		Inputs.RIGHT: Vector2.RIGHT * size
		}

func getDirectionVector(direction:String) -> Vector2:
	if(direction in movementVectors):
		return movementVectors[direction]
	else:
		return Vector2.ZERO

func isMoveValid(direction:String) -> bool:
	return (
		(direction in movementVectors)
		&& !isColliding(direction)
	)

func moveTile(direction:String, moveTime:float = moveTimeTile) -> GDScriptFunctionState:
	if(directionCurrent != direction):
		directionCurrent = direction
		emit_signal("direction_changed", direction)
	if(isMoveValid(direction)):
		if(moveTween(movementVectors[direction], moveTime) != null):
			isMoving = true
			yield(movingTween, "tween_completed")
			isMoving = false
	emit_signal("move_completed")
	return null

func moveStep(direction:String, tiles:int = 1, delay:float = moveDelayTile) -> GDScriptFunctionState:
	for n in tiles:
		if(moveTile(direction) != null):
			yield(movingTween, "tween_completed")
			snap()
			if(timer.begin(delay) != null):
				yield(timer, "timeout")
		else:
			if(timer.begin(delay) != null):
				yield(timer, "timeout")
	
	emit_signal("step_completed")
	return null

func movePath(
	pathDirections:PoolStringArray, pathSteps:PoolIntArray,
	loopType = PathTypes.default,
	delayTile:float = moveDelayTile, delayStep:float = moveDelayStep
) -> GDScriptFunctionState:
	 
	_pathSize = min(pathDirections.size(), pathSteps.size()) as int
	
	match(loopType):
		PathTypes.opposite:
			for i in _pathSize:
				if(moveStep(getOppositeDirection(pathDirections[i]), pathSteps[i], delayTile) != null):
					yield(self, "step_completed")
					if(timer.begin(delayStep) != null):
						yield(timer, "timeout")
				else:
					if(timer.begin(delayStep) != null):
						yield(timer, "timeout")
		PathTypes.inverted:
			for i in range(_pathSize-1, -1, -1):
				if(moveStep(getOppositeDirection(pathDirections[i]), pathSteps[i], delayTile) != null):
					yield(self, "step_completed")
					if(timer.begin(delayStep) != null):
						yield(timer, "timeout")
				else:
					if(timer.begin(delayStep) != null):
						yield(timer, "timeout")
		_:
			for i in _pathSize:
				if(moveStep(pathDirections[i], pathSteps[i], delayTile) != null):
					yield(self, "step_completed")
					if(timer.begin(delayStep) != null):
						yield(timer, "timeout")
				else:
					if(timer.begin(delayStep) != null):
						yield(timer, "timeout")
	
	emit_signal("path_completed")
	return null

func moveTween(directionVector:Vector2, moveTime:float = moveTimeTile) -> GDScriptFunctionState:
# warning-ignore:return_value_discarded
	if(moveTimeTile > 0.0):
		movingTween.interpolate_property(
			self, "position",
			position, position + directionVector,
			moveTime,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN
			)
# warning-ignore:return_value_discarded
		movingTween.start()
		yield(movingTween, "tween_completed")
	else:
		position += directionVector
	
	return null

func snap():
	position += Vector2.ONE * tileSize*0.5
	position = position.snapped(Vector2.ONE * tileSize)
	position -= Vector2.ONE * tileSize*0.5

func isColliding(direction:String) -> bool:
	collisionRay.cast_to = movementVectors[direction]
	collisionRay.force_raycast_update()
	return collisionRay.is_colliding()

static func getOppositeDirection(direction:String) -> String:
	match(direction):
		Inputs.UP: return Inputs.DOWN
		Inputs.DOWN: return Inputs.UP
		Inputs.LEFT: return Inputs.RIGHT
		Inputs.RIGHT: return Inputs.LEFT
		_: return ""
