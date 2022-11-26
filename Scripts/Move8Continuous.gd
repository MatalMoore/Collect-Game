extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"ba = 0

var speed = 600
var velocity = Vector2()

# Called when the node enters the scene tree for the first time.
func get_input():
	velocity = Vector2(0,0)
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	velocity = velocity.normalized() * speed

func _physics_process(_delta):
	get_input()
	velocity = move_and_slide(velocity)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
