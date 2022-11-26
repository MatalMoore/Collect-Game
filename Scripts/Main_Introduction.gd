extends Node2D

onready var camera:Camera2D = get_node(@"/root/Main/CameraMain")

func _onready():
	camera.make_current()

func _input(event):
	if(event.is_action_pressed("quit")):
		queue_free()
		get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
	if(event.is_action_pressed("confirm")):
# warning-ignore:return_value_discarded
		get_tree().change_scene("Base.tscn")

func reset():
# warning-ignore:return_value_discarded
	get_tree().change_scene(get_tree().get_current_scene().get_filename())
	queue_free()
