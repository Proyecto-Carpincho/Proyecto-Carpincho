extends StateMachine

@onready var Parent:CharacterBody2D=get_parent()
@export var DashNode:StateMachine
func _ready() -> void:
	SetVelocity()
	SetActualState("Quieto")

func _physics_process(delta: float) -> void:
	ExecutePhysics(delta)

var CountJump:int
var inWall:bool
func _PhysicsMatch(delta:float,State:String) -> void:
	Ui.SetState(State)
	if State in ["Correr","Quieto","Caminar"]:
		Parent.setShapeRotation()
	match State:
		"Quieto":
			Parent.velocity.x = move_toward(Parent.velocity.x,0,delta*250)
			if Parent.inputWalk() != 0:
				SetActualState("Caminar")
			jump()
			if not Parent.isOnFloor() and Parent.shapeIsColliding():
				Parent.velocity.y=0
				SetActualState("Colgado Pared")
			if Parent.shapeIsColliding() and Parent.inputWall() != 0:
				SetActualState("Deslizarse Pared")

		"Caminar":
			Parent.velocity.x += Parent.inputWalk() * Parent.walkVelocity * delta
			
			if abs(Parent.velocity.x)>Parent.maxWalkVelocity:
				Parent.velocity.x=Parent.inputWalk() * Parent.maxWalkVelocity
			
			if Parent.inputWalk() == 0:
				SetActualState("Quieto")
			if Parent.inputRun():
				SetActualState("Correr")
			if Parent.shapeIsColliding():
				Parent.velocity.y=0
				SetActualState("Colgado Pared")
			
			jump()
			
			var Direccion = -1 if Parent.velocity.x < 0 else 1
			
			if Direccion != Parent.inputWalk():
				Parent.velocity.x = Parent.velocity.x*0.9

		"Correr":
			if Parent.inputWalk()!=0:
				Parent.velocity.x += Parent.inputWalk() * Parent.runVelocity * delta
				if abs(Parent.velocity.x)>Parent.maxRunVelocity:
					
					Parent.velocity.x=Parent.inputWalk() * Parent.maxRunVelocity
				
				var Direccion = -1 if Parent.velocity.x < 0 else 1
			
				if Direccion != Parent.inputWalk():
					Parent.velocity.x = Parent.velocity.x*0.9
			
			if Parent.inputWalk() == 0 and not Parent.inputRun():
				SetActualState("Quieto")
			if not Parent.inputRun():
				SetActualState("Caminar")
			if Parent.shapeIsColliding():
				Parent.velocity.y=0
				SetActualState("Colgado Pared")
			
			jump(Parent.jumpMultiplyBoosted)

		"Colgado Pared":
			inWall= true
			if Parent.isOnFloor() or (not Parent.shapeIsColliding() and not Parent.isOnFloor()):
				SetActualState("Quieto")
				inWall= false
			if Parent.inputWall() != 0:
				Parent.velocity.y=0
				SetActualState("Deslizarse Pared")
			if Parent.velocity.y<0:
				
				Parent.velocity.y = Parent.velocity.y *0.1
				
			wallJump()

		"Deslizarse Pared":
			inWall= true
			Parent.velocity.y = Parent.wallVelocity * 1.5 * Parent.inputWall() * delta
			if Parent.isOnFloor() or (not Parent.shapeIsColliding() and not Parent.isOnFloor()):
				SetActualState("Quieto")
				inWall= false
			if Parent.inputWall() == 0:
				Parent.velocity.y=0
				SetActualState("Colgado Pared")
			wallJump()

		"Muerte":
			pass

	#Default
	var EnDash:bool =DashNode.EnDash
	if DashNode:
		EnDash =DashNode.EnDash
	
	if not Parent.isOnFloor() and not EnDash:
		var multiplyGravity:float= 1 if not inWall else Parent.gravityMultiplyWall
		if Parent.velocity.y < Parent.maxGravity * multiplyGravity or State=="Deslizarse Pared":
			Parent.velocity.y += Parent.gravity * multiplyGravity * delta
		else:
			Parent.velocity.y = Parent.maxGravity * multiplyGravity
	
	
	if Parent.life == 0:
		SetActualState("Muerte")
	#lo pongo aca por que x
	if Input.is_action_just_pressed("Bullet Time") and Cooldown and Parent.buTimeIsActive:
		Cooldown = false
		EfectosVisuales.RelentizarTiempo(0.3)
		await get_tree().create_timer(0.15).timeout
		Engine.time_scale = 0.35
		await get_tree().create_timer(Parent.bulletTimesec).timeout
		EfectosVisuales.RelentizarTiempo(1,false)
		Engine.time_scale = 1
		Parent.get_node("Cooldown Bullet Time").wait_time = Parent.Cooldown
		Parent.get_node("Cooldown Bullet Time").start()
		Ui.RecargaDash(Parent.Cooldown)
	
	if Input.is_action_just_pressed("Dash")and(DashNode.ActualState.find("Dash") == -1):
		DashNode.InicioEstado = true
		DashNode.SetActualState("Dash")
	
	Parent.move_and_slide()
var Cooldown:bool=true

var Jumping:bool
var ExtraJump:bool
var boolJump
func jump(Multiply:float=1.0)->void:
	if Parent.inputJump():
		if Parent.is_on_floor() or Parent.isOnFloor():
			CountJump=Parent.extraJump
			Jumping=true
			boolJump=true
		elif CountJump!=0:
			CountJump-=1
			Jumping=true
			ExtraJump=true
	if Parent.is_on_floor():
		CountJump=Parent.extraJump
	if Jumping:
		if not ExtraJump:
			Parent.velocity.y+=Parent.velocityJump*Multiply* 0.1
			if Parent.velocity.y < Parent.velocityJump*Multiply or not Parent.inputIsJumping():
				Jumping=false
		else:
			ExtraJump=false
			Parent.velocity.y=Parent.velocityJump*Multiply
			


var wallDirection:int
func wallJump()->void:
	##hay un bug donde cuando se pone una posicion muy justa y saltas estando en el estado "quieto" salta y la variable Jumping hace cosas raras y se pone a volar
	if Parent.inputJump():
		if Parent.shapeIsColliding():
			CountJump=Parent.extraJump
			Jumping=true
			wallDirection=Parent.getShapeDireccion()
			Parent.velocity.y=0
	if Jumping:
		if wallDirection == 0:
			wallDirection=Parent.getShapeDireccion()
		Parent.setShapeRotation(-1 * wallDirection)
		if not Parent.shapeIsColliding():
			Parent.velocity.y+=Parent.velocityJump* 0.8
			Parent.velocity.x=-1 * wallDirection * Parent.runVelocity * 1.5
		
	else:
		wallDirection=0


func _on_bullet_time_timeout() -> void:
	Cooldown = true
