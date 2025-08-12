extends StateMachine

@export var Player:CharacterBody2D=get_parent()
@export var DashNode:Node2D
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
		Player.setShapeRotation()
	match State:
		"Quieto":
			Player.velocity.x = move_toward(Player.velocity.x,0,delta*250)
			if Player.inputWalk() != 0:
				SetActualState("Caminar")
			jump()
			if not Player.is_on_floor() and Player.isOnWall():
				Player.velocity.y=0
				SetActualState("Colgado Pared")
			if Player.isOnWall() and Player.inputWall() != 0:
				SetActualState("Deslizarse Pared")

		"Caminar":
			Player.velocity.x += Player.inputWalk() * Player.walkVelocity * delta
			
			if abs(Player.velocity.x)>Player.maxWalkVelocity:
				Player.velocity.x=Player.inputWalk() * Player.maxWalkVelocity
			
			if Player.inputWalk() == 0:
				SetActualState("Quieto")
			if Player.inputRun():
				SetActualState("Correr")
			if Player.isOnWall():
				Player.velocity.y=0
				SetActualState("Colgado Pared")
			
			jump()
			
			var Direccion = -1 if Player.velocity.x < 0 else 1
			
			if Direccion != Player.inputWalk():
				Player.velocity.x = Player.velocity.x*0.9

		"Correr":
			if Player.inputWalk()!=0:
				Player.velocity.x += Player.inputWalk() * Player.runVelocity * delta
				if abs(Player.velocity.x)>Player.maxRunVelocity:
					
					Player.velocity.x=Player.inputWalk() * Player.maxRunVelocity
				
				var Direccion = -1 if Player.velocity.x < 0 else 1
			
				if Direccion != Player.inputWalk():
					Player.velocity.x = Player.velocity.x*0.9
			
			if Player.inputWalk() == 0 and not Player.inputRun():
				SetActualState("Quieto")
			if not Player.inputRun():
				SetActualState("Caminar")
			if Player.isOnWall():
				Player.velocity.y=0
				SetActualState("Colgado Pared")
			
			jump(Player.jumpMultiplyBoosted)

		"Colgado Pared":
			inWall= true
			if Player.is_on_floor() or (not Player.isOnWall()):
				SetActualState("Quieto")
				inWall= false
			if Player.inputWall() != 0:
				Player.velocity.y=0
				SetActualState("Deslizarse Pared")
			if Player.velocity.y<0:
				
				Player.velocity.y = Player.velocity.y *0.1
				
			wallJump()

		"Deslizarse Pared":
			inWall= true
			Player.velocity.y = Player.wallVelocity * 1.5 * Player.inputWall() * delta
			if Player.isOnFloor() or (not Player.isOnWall() and not Player.is_on_floor()):
				SetActualState("Quieto")
				inWall= false
			if Player.inputWall() == 0:
				Player.velocity.y=0
				SetActualState("Colgado Pared")
			wallJump()

		"Muerte":
			pass

	#Default
	var EnDash:bool =DashNode.EnDash
	if DashNode:
		EnDash =DashNode.EnDash
	
	if not Player.is_on_floor() and not EnDash:
		var multiplyGravity:float= 1 if not inWall else Player.gravityMultiplyWall
		if Player.velocity.y < Player.maxGravity * multiplyGravity or State=="Deslizarse Pared":
			Player.velocity.y += Player.gravity * multiplyGravity * delta
		else:
			Player.velocity.y = Player.maxGravity * multiplyGravity
	
	
	if Player.life == 0:
		SetActualState("Muerte")
	#lo pongo aca por que x
	if Input.is_action_just_pressed("Bullet Time") and Cooldown and Player.buTimeIsActive:
		Cooldown = false
		EfectosVisuales.RelentizarTiempo(0.3)
		await get_tree().create_timer(0.15).timeout
		Engine.time_scale = 0.35
		await get_tree().create_timer(Player.bulletTimesec).timeout
		EfectosVisuales.RelentizarTiempo(1,false)
		Engine.time_scale = 1
		Player.get_node("Cooldown Bullet Time").wait_time = Player.Cooldown
		Player.get_node("Cooldown Bullet Time").start()
		Ui.RecargaBulletTime(Player.Cooldown)
	
	if Input.is_action_just_pressed("Dash")and(DashNode.ActualState.find("Dash") == -1):
		DashNode.InicioEstado = true
		DashNode.SetEstadoActual("Dash")
	
	Player.move_and_slide()
var Cooldown:bool=true

var Jumping:bool
var ExtraJump:bool
var boolJump
func jump(Multiply:float=1.0)->void:
	if Player.inputJump():
		if Player.is_on_floor():
			CountJump=Player.extraJump
			Jumping=true
			boolJump=true
		elif CountJump!=0:
			CountJump-=1
			Jumping=true
			ExtraJump=true
	if Player.is_on_floor():
		CountJump=Player.extraJump
	if Jumping:
		if not ExtraJump:
			Player.velocity.y+=Player.velocityJump*Multiply* 0.1
			if Player.velocity.y < Player.velocityJump*Multiply or not Player.inputIsJumping():
				Jumping=false
		else:
			ExtraJump=false
			Player.velocity.y=Player.velocityJump*Multiply
			


var wallDirection:int
func wallJump()->void:
	##hay un bug donde cuando se pone una posicion muy justa y saltas estando en el estado "quieto" salta y la variable Jumping hace cosas raras y se pone a volar
	if Player.inputJump():
		if Player.isOnWall():
			CountJump=Player.extraJump
			Jumping=true
			wallDirection=Player.getShapeDireccion()
			Player.velocity.y=0
	if Jumping:
		if wallDirection == 0:
			wallDirection=Player.getShapeDireccion()
		Player.setShapeRotation(-1 * wallDirection)
		if not Player.isOnWall():
			Player.velocity.y+=Player.velocityJump* 0.8
			Player.velocity.x=-1 * wallDirection * Player.runVelocity * 1.5
		
	else:
		wallDirection=0


func _on_bullet_time_timeout() -> void:
	Cooldown = true
