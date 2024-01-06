extends CharacterBody2D

@onready var my_type = "flag"
var gravity = 16.2

func _physics_process(delta):
	velocity.y += gravity
	move_and_slide()
