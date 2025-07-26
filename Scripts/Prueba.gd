extends StateMachine

@onready var Parent:CharacterBody2D=get_parent()
func _ready() -> void:
	SetVelocity()
	SetActualState("Quieto")

func _process(delta: float) -> void:
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
			if Parent.inputWall() !=0:
				Parent.velocity.y=0
				SetActualState("Deslizarse Pared")
			if Parent.velocity.y<0:
				Parent.velocity.y = Parent.velocity.x*0.5
			wallJump()

		"Deslizarse Pared":
			inWall= true
			Parent.velocity.y = Parent.wallVelocity * Parent.inputWall() * delta
			if Parent.isOnFloor() or (not Parent.shapeIsColliding() and not Parent.isOnFloor()):
				SetActualState("Quieto")
				inWall= false
			if Parent.inputWall()==0:
				Parent.velocity.y=0
				SetActualState("Colgado Pared")
			wallJump()

		"Muerte":
			pass

	#Default
	if not Parent.isOnFloor():
		var multiplyGravity:float= 1 if not inWall else Parent.gravityMultiplyWall
		if Parent.velocity.y < Parent.maxGravity:
			Parent.velocity.y += Parent.gravity * multiplyGravity * delta
		else:
			Parent.velocity.y = Parent.maxGravity * multiplyGravity
	
	if Parent.life == 0:
		SetActualState("Muerte")
	Parent.move_and_slide()

var Jumping:bool
var ExtraJump:bool
func jump(Multiply:float=1.0)->void:
	if Parent.inputJump():
		if Parent.isOnFloor():
			CountJump=Parent.extraJump
			Jumping=true
		elif CountJump!=0:
			CountJump-=1
			Jumping=true
			ExtraJump=true
	if Jumping:
		if not ExtraJump:
			Parent.velocity.y+=Parent.velocityJump*Multiply* 0.1
			if Parent.velocity.y < Parent.velocityJump*Multiply or not Parent.inputIsJumping():
				Jumping=false
		else:
			ExtraJump=false
			Parent.velocity.y+=Parent.velocityJump*Multiply


var wallDirection:int
func wallJump()->void:
	if Parent.inputJump():
		if Parent.shapeIsColliding():
			CountJump=Parent.extraJump
			Jumping=true
			wallDirection=Parent.getShapeDireccion()
	if Jumping:
		Parent.velocity.y+=Parent.velocityJump* 0.5
		Parent.velocity.x=-1 * wallDirection * Parent.runVelocity * 1.5
		Parent.setShapeRotation(-1 * wallDirection)
