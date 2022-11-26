extends Node2D

const MyTimer = preload("./MyTimer.gd")
const InterfacePopup = preload("./InterfacePopup.gd")
const PlayerEvents = preload("./PlayerEvents.gd")

onready var popups:CanvasLayer = get_node(@"/root/Main/Popups")
onready var popup_PlayerHit:InterfacePopup = get_node(@"/root/Main/Popups/PlayerHit")
onready var popup_PlayerWin:InterfacePopup = get_node(@"/root/Main/Popups/PlayerWin")
onready var camera:Camera2D = get_node(@"/root/Main/CameraMain")
onready var playerEvents:PlayerEvents = get_node(@"/root/Main/Objects/Player/PlayerEvents")

onready var timer:MyTimer = MyTimer.new()

onready var hasWon:bool = false

func _ready():
# warning-ignore:return_value_discarded
	playerEvents.connect("player_hit", self, "reset")
	add_child(timer)
	popup_PlayerHit.hide()
	popup_PlayerWin.hide()
	camera.make_current()
# warning-ignore:return_value_discarded
	playerEvents.connect("player_win", self, "on_player_win")

func _input(event):
	if(event.is_action_pressed("quit")
		|| hasWon && event.is_action_pressed("confirm")
	):
		queue_free()
		get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

func reset():
# warning-ignore:return_value_discarded
	get_tree().change_scene(get_tree().get_current_scene().get_filename())
	queue_free()

func on_player_win():
	hasWon = true
