extends "./GridMovement.gd"

export(float) var moveDelayLoop = 0.0
export(bool) var isLooping = true
export(String) var LoopTypeString = "opposite" setget set_loopType
export(Array, String) var pathDirections = [Inputs.LEFT]
export(Array, int) var pathSteps = [1]

var loopType = PathTypes.opposite

func _ready():
	set_process(isLooping)

func _process(_float):
	set_process(false)
	
	if(movePath(pathDirections, pathSteps) != null):
		yield(self, "path_completed")
		if(timer.begin(moveDelayLoop) != null):
			yield(timer, "timeout")
	else:
		if(timer.begin(moveDelayLoop) != null):
			yield(timer, "timeout")
	
	if(loopType != PathTypes.default):
		if(movePath(pathDirections, pathSteps, loopType) != null):
			yield(self, "path_completed")
			if(timer.begin(moveDelayLoop) != null):
				yield(timer, "timeout")
		else:
			if(timer.begin(moveDelayLoop) != null):
				yield(timer, "timeout")
	
	set_process(isLooping)

func set_loopType(type:String):
	LoopTypeString = type
	if(type in PathKeys):
		loopType = PathKeys[type]
	else:
		loopType = PathTypes.default
