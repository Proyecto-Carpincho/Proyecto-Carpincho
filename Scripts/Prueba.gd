extends StateMachine

@onready var Parent:CharacterBody2D=get_parent()
func _ready() -> void:
	SetVelocity()
	SetActualState("Quieto")

func _process(delta: float) -> void:
	ExecutePhysics(delta)

var CountJump:int
func _PhysicsMatch(delta:float,State:String) -> void:
	match State:
		"Quieto":
			Parent.velocity.x = move_toward(Parent.velocity.x,0,delta*250)
			if Parent.inputWalk() != 0:
				SetActualState("Caminar")
			Jump(delta)

		"Caminar":
			Parent.velocity.x += Parent.inputWalk() * Parent.walkVelocity * delta
			
			if abs(Parent.velocity.x)>Parent.maxWalkVelocity:
				Parent.velocity.x=Parent.inputWalk() * Parent.maxWalkVelocity
			
			if Parent.inputWalk() == 0:
				SetActualState("Quieto")
			if Parent.inputRun():
				SetActualState("Correr")
			Jump(delta)
			
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
			Jump(delta,Parent.jumpMultiplyBoosted)
			

		"Colgado Pared":
			pass

		"Deslizarse Pared":
			pass

		"Muerte":
			pass
	
	#Default
	if not Parent.is_on_floor():
		if Parent.velocity.y < Parent.maxGravity:
			Parent.velocity.y += Parent.gravity * delta
		else:
			Parent.velocity.y = Parent.maxGravity
	Parent.move_and_slide()
var Jumping:bool
func Jump(delta:float,Multiply:float=1.0)->void:
	if Parent.inputJump():
		if Parent.is_on_floor():
			CountJump=Parent.extraJump
			Jumping=true
		elif CountJump!=0:
			CountJump-=1
			Jumping=true
	if Jumping:
		Parent.velocity.y+=Parent.velocityJump*Multiply* 0.1
		if Parent.velocity.y < Parent.velocityJump*Multiply or not Parent.inputIsJumping():
			Jumping=false
