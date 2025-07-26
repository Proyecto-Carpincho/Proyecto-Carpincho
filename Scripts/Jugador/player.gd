extends CharacterBody2D

@export_group("Life")
@export var maxLife:int
@export var life:int

@export_group("Gravity")
@export var gravity:float
@export var maxGravity:float
@export_range(0,1,0.01) var gravityMultiplyWall:float

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

@export_group("Wall")
@export var wallVelocity:float


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

func setShapeRotation(OtherRotation:int=0)->void:
	var auxDirection:int=inputWalk() if OtherRotation == 0 else OtherRotation
	if auxDirection!=0:
		auxDirection= 0 if auxDirection == 1 else 180
		get_node("Shape Pared").set_rotation_degrees(auxDirection)

func shapeIsColliding()->bool:
	return get_node("Shape Pared").is_colliding()

func getShapeDireccion()->int:
	return 1 if get_node("Shape Pared").get_rotation_degrees() != 180 else -1

func isOnFloor()->bool:
	return get_node("Shape Piso").is_colliding()
