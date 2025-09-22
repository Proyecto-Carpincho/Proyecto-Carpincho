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
@export var extra_jump:int
@export var extra_jump_boost:float
@export var velocity_jump:float
@export var jump_multiply_boosted:float

@export_group("Wall")
@export var wall_velocity:float
@export var wall_jump_velocity:float


func inputWalk()->float:
	return Input.get_axis("Move Left","Move Right")

func inputWall()->float:
	return Input.get_axis("Move Down","Move Up")

func inputRun()->bool:
	return Input.is_action_pressed("Run")

func inputJump()->bool:
	return Input.is_action_just_pressed("Jump")

func inputIsJumping()->bool:
	return Input.is_action_pressed("Jump")

##0 o cualquier otro numero es 180° y 1 es 0°. Recomiendo que lo que envie sea 1 o 0 para mayor control, por que solo considera al 1 como derecha y cualquier otro numero como izquierda, asi que puede usar 1 y cualquier otro numero, pero por estandar use 0
func setShapeRotation(other_rotation:int=0)->void:
	var aux_direction:int= int(inputWalk()) if other_rotation == 0 else other_rotation
	if aux_direction!=0:
		
		aux_direction= 0 if aux_direction == 1 else 180
		get_node("Shape Pared").set_rotation_degrees(aux_direction)

func isOnWall()->bool:
	return get_node("Shape Pared").is_colliding()

func getShapeDireccion()->int:
	return 1 if get_node("Shape Pared").get_rotation_degrees() != 180 else -1
