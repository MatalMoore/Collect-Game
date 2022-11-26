extends Timer

func begin(time:float) -> GDScriptFunctionState:
	#a time of 0.0 may have undesirable results
	if(time > 0.0):
		set_wait_time(time)
		set_one_shot(true)
		start()
		yield(self, "timeout")
	
	return null
