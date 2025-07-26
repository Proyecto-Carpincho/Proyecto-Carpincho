extends CharacterBody2D

@export_group("Gravity")
@export var gravity:float
@export var maxGravity:float
@export_range(0,1,0.05) var gravityMultiplyWall:float

@export_group("Walk")
@export var walkVelocity:float
@export var maxWalkVelocity:float

@export_group("Run")
@export var runVelocity:float
@export var maxRunVelocity:float

@export_group("Jump")
@export var extraJump:int
@export var velocityJump:float
@export var jumpMultiplyBoosted:float



func inputWalk()->int:
	return Input.get_axis("Move Left","Move Right")

func inputWall()->int:
	return Input.get_axis("Move Down","Move Up")

func inputRun()->bool:
	return Input.is_action_pressed("Run")

func inputJump()->bool:
	return Input.is_action_just_pressed("Jump")

func inputIsJumping()->bool:
	return Input.is_action_pressed("Jump")
