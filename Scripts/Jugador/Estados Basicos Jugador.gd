extends StateMachine


"""
	Estados Basicos Jugador:
		#Funcion:
			Ser los la maquina de estado principal del jugador
		#Notas:
			Aun esta en proceso asi que no es del todo entendible su funcionamiento 
			(especialmente en nombres de funciones y variables). 
			Voy poco a poco mejorando eso
			tiene 248 lineas 👀 siempre llego a casi las 300 por alguna razon (Te estoy viendo Cinematic Player)"""

#region Variables
@export var Player:CharacterBody2D=get_parent()
##Nodo padre de la escena Dash
@export var DashNode:Node2D

var CountJump:int
var inWall:bool
var Cooldown:bool=true
var Jumping:bool
var ExtraJump:bool
var IsInCoyoteTime:bool
var a:bool #Buen nombre eh
var wallDirection:int
var InFloor:bool


#region Timers
@onready var TimerBulletTime:Timer = Player.get_node("Cooldown Bullet Time")
@onready var TimerCoyote:Timer = Player.get_node("Timer Coyote")
#endregion
#endregion Variables


func _ready() -> void:
	SetActualState("Quieto")

func _physics_process(delta: float) -> void:
	ExecutePhysics(delta)


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
			InputToWall()

		"Caminar":
			Player.velocity.x += Player.inputWalk() * Player.walkVelocity * delta
			
			if abs(Player.velocity.x)>Player.maxWalkVelocity:
				Player.velocity.x=Player.inputWalk() * Player.maxWalkVelocity
			
			if Player.inputWalk() == 0:
				SetActualState("Quieto")
			if Player.inputRun():
				SetActualState("Correr")
			InputToWall()
			
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
			InputToWall()
			
			jump(Player.jumpMultiplyBoosted)

		"Colgado Pared":
			inWall= true
			if Player.is_on_floor() or not Player.isOnWall():
				SetActualState("Quieto")
				inWall= false
				
			if Player.inputWall() != 0:
				Player.velocity.y = 0
				SetActualState("Deslizarse Pared")
				
			if Player.velocity.y < 0:
				
				Player.velocity.y = Player.velocity.y *0.1
				
			wallJump()

		"Deslizarse Pared":
			inWall= true
			Player.velocity.y = Player.wallVelocity * 1.5 * Player.inputWall() * delta
			if (Player.is_on_floor() and Player.inputWall() == 0) or (not Player.isOnWall() and not Player.is_on_floor()):
				SetActualState("Quieto")
				inWall = false
				
			if Player.inputWall() == 0:
				Player.velocity.y = 0
				SetActualState("Colgado Pared")
				
			wallJump()

		"Muerte":
			pass

	#region Default cosas que todos los estados comparten
	
	
	var EnDash:bool =DashNode.EnDash
	if DashNode:
		EnDash =DashNode.EnDash
	

	#Gravedad
	#este if actua cuando no esta en el piso, no tiene coyote time y ademas no esta Dasheando
	if (not Player.is_on_floor() and TimerCoyote.is_stopped()) and not EnDash:
		var multiplyGravity:float= 1 if not inWall else Player.gravityMultiplyWall
		
		if Player.velocity.y < (Player.maxGravity * multiplyGravity) or State=="Deslizarse Pared":
			Player.velocity.y += Player.gravity * multiplyGravity * delta
		else:
			Player.velocity.y = Player.maxGravity * multiplyGravity
	
	#estado para morir
	if Player.life == 0:
		#Aun no tiene nada por que no tenemos interfaz aun para poner algo como "te moriste we"
		SetActualState("Muerte")
	#region Bullet time
	if Input.is_action_just_pressed("Bullet Time") and Cooldown and Player.buTimeIsActive:
		Cooldown = false
		EfectosVisuales.RelentizarTiempo(0.3)
		await get_tree().create_timer(0.15).timeout
		Engine.time_scale = 0.35
		await get_tree().create_timer(Player.bulletTimesec).timeout
		EfectosVisuales.RelentizarTiempo(1,false)
		Engine.time_scale = 1
		TimerBulletTime.wait_time = Player.Cooldown
		TimerBulletTime.start()
		Ui.RecargaBulletTime(Player.Cooldown)
	#endregion Bullet time
	
	#Input Dash
	if Input.is_action_just_pressed("Dash")and(DashNode.ActualState.find("Dash") == -1):
		#dato importante uso al nodo que es padre del state machine como intermediario. 
		#Ya que como es una escena distinta no puedo acceder a sus nodos hijos (bueno si puedo pero no debo)
		DashNode.InicioEstado = true
		DashNode.SetEstadoActual("Dash")
	CoyoteTime()
	Player.move_and_slide()
	#endregion


func InputToWall():
	if not Player.is_on_floor() and Player.isOnWall():
		Player.velocity.y=0
		SetActualState("Colgado Pared")
	if Player.isOnWall() and Player.inputWall() != 0:
		SetActualState("Deslizarse Pared")


func jump(Multiply:float=1.0)->void:
	if Player.is_on_floor():
		a = true
	if Player.inputJump():
		if Player.is_on_floor() or (IsInCoyoteTime and a):
			a = false
			CountJump=Player.extraJump
			Jumping=true
			if IsInCoyoteTime:
				Player.velocity.y = 0 
				IsInCoyoteTime = false
				TimerCoyote.stop()
		elif CountJump!=0:
			if Player.velocity.y < 0:
				Player.velocity.y = 0
			 
			CountJump-=1
			Jumping=true
			ExtraJump=true
	if Player.is_on_floor():
		CountJump=Player.extraJump
	
	#el input y el salto estan en partes distintas para hacer que el jugador pueda nivelar la fuerza del salto hasta un maximo
	if Jumping:
		if not ExtraJump:
			Player.velocity.y+=Player.velocityJump*Multiply* 0.25
			if Player.velocity.y < Player.velocityJump*Multiply or not Player.inputIsJumping():
				Jumping=false
		else:
			ExtraJump=false
			Player.velocity.y=Player.velocityJump*Multiply* Player.extraJumpBoost


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
			Player.velocity.y+=Player.wallJumpVelocity
			Player.velocity.x=-1 * wallDirection * Player.runVelocity * 1.5
		
	else:
		wallDirection=0

func _on_bullet_time_timeout() -> void:
	Cooldown = true

func CoyoteTime():
	if Player.is_on_floor():
		TimerCoyote.stop()
		InFloor = true
		IsInCoyoteTime = false
	elif TimerCoyote.is_stopped() and InFloor:
		TimerCoyote.start()
		InFloor =false
		IsInCoyoteTime = true

func _on_timer_coyote_timeout() -> void:
	IsInCoyoteTime = false
