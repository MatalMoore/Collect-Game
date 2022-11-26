extends Node2D

const MyTimer = preload("./MyTimer.gd")
const Entity = preload("./Entity.gd")
const Player = preload("./Player_MovementInput.gd")
const Collectible = preload("./Collectible.gd")
const CollectibleCount = preload("./CollectibleCount.gd")
const Door = preload("./Door.gd")
const GridMovementInput = preload("./GridMovementInput.gd")
const InterfacePopup = preload("./InterfacePopup.gd")

signal player_hit
signal player_win

onready var player:Player = get_node(@"/root/Main/Objects/Player/Entity")
onready var exit:Entity = get_node(@"/root/Main/Objects/Background/Doors/Exit")
onready var collectiblesRemaining:CollectibleCount = get_node(@"/root/Main/HUD/CollectiblesRemaining/Number")
onready var popupHit:InterfacePopup = get_node(@"/root/Main/Popups/PlayerHit")
onready var popupWin:InterfacePopup = get_node(@"/root/Main/Popups/PlayerWin")
onready var popupDoorOpen:InterfacePopup = get_node(@"/root/Main/Popups/DoorOpen")

onready var timer:MyTimer = MyTimer.new()

onready var stored_moveTimeTile:float = player.moveTimeTile

onready var directionSlide:String = ""
onready var positionSlide:Vector2 = Vector2.ZERO
onready var isPlayerSliding:bool = false

onready var null_entity:Entity = Entity.new()
onready var playerCollidingEntity:Entity = null_entity

func _ready():
# warning-ignore:return_value_discarded
	player.connect("collided_Entity", self, "player_has_collided")
# warning-ignore:return_value_discarded
	player.connect("area_entered", self, "on_area_entered")
	add_child(timer)

func player_has_collided(movingEntity:Entity, collidingEntity:Entity):
	if(movingEntity != null && collidingEntity != null):
		match(collidingEntity.type):
			"enemy":
				on_player_hit()
			"collectible":
				on_collectible_get(collidingEntity)
			"hindrance":
				on_hindrance_enter(collidingEntity)
			"slider":
				on_slider_enter(collidingEntity)
			_:
				pass

func on_area_entered(area:Area2D):
	if(area == exit.area):
		popupWin.show(0.0, 0.2)
		emit_signal("player_win")
		if(player.isMoving):
			player.set_process(false)
			player.set_process_input(false)
			yield(player, "move_completed")
			player.moveTile(GridMovementInput.Inputs.DOWN)

func on_player_hit():
	player.hit()
	popupHit.show(0.0, 0.2)
	timer.begin(2.0)
	yield(timer, "timeout")
	emit_signal("player_hit")

func on_collectible_get(collectible:Entity):
	collectible.action("collect")
	if(collectiblesRemaining.count > 0):
		collectiblesRemaining.add(-1)
		if(collectiblesRemaining.count <= 0):
			exit.open()
			popupDoorOpen.show(1.0, 0.35, 0.35)

func on_hindrance_enter(hindrance:Entity):
# warning-ignore:return_value_discarded
	hindrance.connect("area_exited", self, "on_hindrance_exit", [hindrance])
	
	if(playerCollidingEntity.type != "hindrance"):
		stored_moveTimeTile = player.moveTimeTile
	
	player.moveTimeTile = stored_moveTimeTile*hindrance.floatFactor
	playerCollidingEntity = hindrance

func on_hindrance_exit(exitingArea:Area2D, hindrance:Entity):
	if(exitingArea == player):
		hindrance.disconnect("area_exited", self, "on_hindrance_exit")
		if(playerCollidingEntity == hindrance):
			playerCollidingEntity = null_entity
		if(playerCollidingEntity.type != "hindrance"):
			player.moveTimeTile = stored_moveTimeTile

func on_slider_enter(slider:Entity):
# warning-ignore:return_value_discarded
	slider.connect("area_exited", self, "on_slider_exit", [slider])
	
	player.set_process(false)
	player.set_process_input(false)
	directionSlide = player.directionCurrent
	
	if(playerCollidingEntity.type == "slider"):
		playerCollidingEntity = slider
	elif(playerCollidingEntity.type != "slider"):
		if(player.isMoving):
			playerCollidingEntity = slider
			isPlayerSliding = true
			yield(player, "move_completed")
		
			while(isPlayerSliding):
				#ensures positionSlide is different from player.position
				positionSlide = player.position
				positionSlide.x += 1.0
				while(positionSlide != player.position && player.isMoveValid(directionSlide) && isPlayerSliding):
					positionSlide = player.position
					if(player.moveTile(directionSlide, player.moveTimeTile) != null):
						yield(player, "move_completed")
				player.set_process_input(true)
				directionSlide = yield(player, "input_direction")

func on_slider_exit(exitingArea:Area2D, slider:Entity):
	if(exitingArea == player):
		slider.disconnect("area_exited", self, "on_slider_exit")
		if(playerCollidingEntity == slider):
			playerCollidingEntity = null_entity
		if(playerCollidingEntity.type != "slider"):
			isPlayerSliding = false
			if(player.isMoving):
				yield(player, "move_completed")
			player.resetInput()
			player.set_process(true)
			player.set_process_input(true)
