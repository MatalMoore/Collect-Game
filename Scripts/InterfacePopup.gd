extends Control

const MyTimer = preload("./MyTimer.gd")

var timer:MyTimer
var fadeTween:Tween

const COLOR_VISIBLE = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_INVISIBLE = Color(1.0, 1.0, 1.0, 0.0)

func _ready():
	timer = MyTimer.new()
	fadeTween = Tween.new()
	add_child(timer)
	add_child(fadeTween)

func show(duration:float = 0.0, fadeIn:float = 0.0, fadeOut:float = 0.0):
	if(fadeIn > 0.0):
		self.modulate = COLOR_INVISIBLE
		self.visible = true
# warning-ignore:return_value_discarded
		fadeTween.interpolate_property(self, "modulate", self.modulate, COLOR_VISIBLE, fadeIn, Tween.TRANS_LINEAR, Tween.EASE_IN)
# warning-ignore:return_value_discarded
		fadeTween.start()
		yield(fadeTween, "tween_completed")
	else:
		self.visible = true
		self.modulate = COLOR_VISIBLE
	
	if(duration > 0.0):
		timer.start(duration)
		yield(timer, "timeout")
		hide(fadeOut)

func hide(fadeOut:float = 0.0):
	if(fadeOut > 0.0):
# warning-ignore:return_value_discarded
		fadeTween.interpolate_property(self, "modulate", self.modulate, COLOR_INVISIBLE, fadeOut, Tween.TRANS_LINEAR, Tween.EASE_IN)
# warning-ignore:return_value_discarded
		fadeTween.start()
		yield(fadeTween, "tween_completed")
	else:
		self.modulate = COLOR_INVISIBLE
	self.visible = false
