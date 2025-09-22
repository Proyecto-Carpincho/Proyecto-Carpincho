extends StateMachine

"""
Estados Básicos del Jugador:
	# Función:
		Esta es la máquina de estados principal del jugador.
		Maneja el movimento, salto, wall jump, wall slide, dash y bullet time.
		
	# Notas:
		⚠️ Todavía en desarrollo → algunos nombres de funciones/variables no están bien pulidos.
		Esta un poquito mal organizado pero un poquito no ma (280+ líneas 👀). 
		En una futura actualizacion mejorare esto, o sea cuando me explote en la cara
"""

#region === Variables principales ===
@export var Player:CharacterBody2D = get_parent()   ## Nodo jugador
@export var AtaqueNodo:ArmaMelee

var CountJump:int                                  ## Saltos restantes (para double-jump o más)
var inWall:bool                                    ## True si el jugador está en la pared
var Jumping:bool                                   ## True mientras se mantiene un salto activo
var extra_jump:bool                                 ## True si se ejecuta un salto extra
var IsInCoyoteTime:bool                            ## True si el jugador puede saltar después de salir del suelo
var a:bool                                         ## Flag auxiliar para control de saltos
var wallDirection:int                              ## Dirección de la pared (-1 izquierda, 1 derecha)
var InFloor:bool                                   ## True si estaba en el piso en el frame anterior
#endregion


#region === Timers ===
@onready var TimerCoyote:Timer = Player.get_node("Timer Coyote")
#endregion


#region === Ciclo de vida ===
func _ready() -> void:
	SetActualState("Quieto")

func _physics_process(delta: float) -> void:
	#esta hecho para que el bullet time no afecte, osea si afecta pero en aparieza, realmente hace que valla a la misma velocidad con y sin bullet time
	ExecutePhysics(delta)
#endregion


#region === Lógica de estados ===
func _PhysicsMatch(delta:float, State:String) -> void:
	## Actualiza la UI con el estado actual
	Ui.SetState(State)

	## Reset de rotación en estados básicos
	if State in ["Correr","Quieto","Caminar","Caida"]:
		Player.setShapeRotation()
		InputToWall()

	# --- Lógica de estados individuales ---
	match State:

		"Quieto":
			Player.velocity.x = move_toward(Player.velocity.x, 0, delta*150)
			if Player.inputWalk() != 0:
				SetActualState("Caminar")
			jump()
			if not Player.is_on_floor() and not Jumping:
				SetActualState("Caida")

		"Caminar":
			MovimientoX(Player.walkVelocity,Player.maxWalkVelocity,delta)
			
			# Transiciones de estado
			if Player.inputWalk() == 0:
				SetActualState("Quieto")
			if Player.inputRun():
				SetActualState("Correr")
			if not Player.is_on_floor() and not Jumping:
				SetActualState("Caida")

			
			jump()
			
			# Cambio de dirección → aplicar freno
			var Direccion = -1 if Player.velocity.x < 0 else 1
			if Direccion != Player.inputWalk():
				Player.velocity.x *= 0.9

		"Correr":
			
			MovimientoX(Player.runVelocity ,Player.maxRunVelocity,delta)
			
			# Transiciones de estado
			if Player.inputWalk() == 0 and not Player.inputRun():
				SetActualState("Quieto")
			if not Player.inputRun():
				SetActualState("Caminar")
			if not Player.is_on_floor() and not Jumping:
				SetActualState("Caida")
			
			
			
			jump(Player.jump_multiply_boosted)

		"Colgado Pared":
			inWall = true
			if Player.is_on_floor() or not Player.isOnWall():
				SetActualState("Quieto")
				inWall = false
				
			if Player.inputWall() != 0:
				Player.velocity.y = 0
				SetActualState("Deslizarse Pared")
				
			if Player.velocity.y < 0:
				Player.velocity.y *= 0.1
				
			wallJump()

		"Deslizarse Pared":
			inWall = true
			Player.velocity.y = Player.wall_velocity* Player.inputWall() * delta * 4 
			if (Player.is_on_floor() and Player.inputWall() == 0) or (not Player.isOnWall() and not Player.is_on_floor()):
				SetActualState("Quieto")
				inWall = false
				
			if Player.inputWall() == 0:
				Player.velocity.y = 0
				SetActualState("Colgado Pared")
				
			wallJump()

		"Caida":
			MovimientoX(Player.walkVelocity,Player.maxWalkVelocity,delta,true,-0.2)
			jump()
			if Player.is_on_floor():
				if Player.inputWalk() == 0 and not Player.inputRun():
					SetActualState("Quieto")
				if Player.inputRun():
					SetActualState("Correr")
				if Player.inputWalk() != 0:
					SetActualState("Caminar")
			
			if not Player.is_on_floor() and Player.isOnWall():
				Player.velocity.y = 0
				SetActualState("Colgado Pared")
			
		"Muerte":
			#*no hace nada*
			pass

		"Estado Intermedio":
			# este estado aproposito no hace nada, es un estado que es para las habilidades modulares
			# es como un estado hueco para lo rellene quien lo necesite (eso sonaba mejor en mi cabeza)
			pass
	#endregion



	#region === Lógica común para todos los estados ===
	# Variables del dash
	# variable bien xd. Pero bueno prefiero que este asi a que sean 5 linas mas de porquria. 1 linea de mierda es mejor que 5 de porqueria
	var dasheando:bool = AtaqueNodo.DashNode.dasheando if AtaqueNodo.DashNode else false

	# Gravedad (si no está en suelo, no hay coyote time y no está en dash)
	if (not Player.is_on_floor() and TimerCoyote.is_stopped()) and not dasheando:
		var multiplyGravity:float = 1 if not inWall else Player.gravityMultiplyWall
		if Player.velocity.y < (Player.maxGravity * multiplyGravity) or State=="Deslizarse Pared":
			Player.velocity.y += Player.gravity * multiplyGravity * delta
		else:
			Player.velocity.y = Player.maxGravity * multiplyGravity

	# Estado de muerte
	#literal no hace nada, es el meme de *no hace nada* como digo, *no hace nada* y no hara nada hasta dentro de un buen rato
	if Player.life == 0:
		SetActualState("Muerte")
	
	if Input.is_action_just_pressed("Ataque"):
		AtaqueNodo.SetArmaState("Manteniendo Ataque")
	
	#endregion

	# Input Dash
	if Input.is_action_just_pressed("Dash") and (AtaqueNodo.DashNode.ActualState.find("Dash") == -1):
		AtaqueNodo.DashNode.inicio_estado = true
		AtaqueNodo.SetDashState("Dash")

	# Coyote Time + movimiento base
	CoyoteTime()
	
	Player.move_and_slide()
#endregion
func MovimientoX(velocidad,velocidad_Max,delta, caida:bool=false,velocidad_cambio_dirreccion:float = 0.75) -> void:
	var direccion = sign(Player.velocity.x)
	
	if Player.is_on_floor() or caida:
		var velocidad_maxima_alcanzada:bool = abs(Player.velocity.x) >= velocidad_Max and not caida
		if Player.inputWalk() != 0:
			if not velocidad_maxima_alcanzada:
				# Acelerar
				Player.velocity.x += Player.inputWalk() * velocidad * delta


			if direccion != sign(Player.inputWalk()) and direccion != 0:
				Player.velocity.x *= velocidad_cambio_dirreccion
				

		# Limitar velocidad máxima usando el signo actual
		if velocidad_maxima_alcanzada:
			var Ns:int = Player.inputWalk() if Player.inputWalk() != 0 else direccion
			const reduccion_velocidad:float = 150
			Player.velocity.x = move_toward(Player.velocity.x,velocidad_Max*Ns,delta * reduccion_velocidad)
			if abs(Player.velocity.x) > 1.5 * velocidad_Max:
				Player.velocity.x = move_toward(Player.velocity.x,velocidad_Max*Ns,delta * reduccion_velocidad * 10)
		
		var dasheando:bool = AtaqueNodo.DashNode.dasheando if AtaqueNodo.DashNode else false
		if abs(Player.velocity.x) > 1.8 * velocidad_Max and not dasheando:
			var Ns:int = Player.inputWalk() if Player.inputWalk() != 0 else direccion
			Player.velocity.x = move_toward(Player.velocity.x,velocidad_Max*Ns,delta * 150 * 35)



#region === Funciones auxiliares ===
func InputToWall():
	## Detecta si debe transicionar a estados de pared
	if not Player.is_on_floor() and Player.isOnWall():
		Player.velocity.y = 0
		SetActualState("Colgado Pared")
	if Player.isOnWall() and Player.inputWall() != 0:
		SetActualState("Deslizarse Pared")


func jump(Multiply:float=1.0) -> void:
	## Maneja salto normal, extra jump y coyote time
	if Player.is_on_floor():
		a = true

	if Player.inputJump():
		if Player.is_on_floor() or (IsInCoyoteTime and a):
			a = false
			CountJump = Player.extra_jump
			Jumping = true
			Player.velocity.y = 0
			if IsInCoyoteTime:
				IsInCoyoteTime = false
				TimerCoyote.stop()
		elif CountJump != 0:
			if Player.velocity.y < 0:
				Player.velocity.y = 0
			CountJump -= 1
			Jumping = true
			extra_jump = true

	if Player.is_on_floor():
		CountJump = Player.extra_jump
	
	# Controla la fuerza del salto (según cuánto se mantiene pulsado)
	if Jumping:
		if not extra_jump:
			Player.velocity.y += Player.velocity_jump * Multiply * 0.15
			if Player.velocity.y < Player.velocity_jump * Multiply or not Player.inputIsJumping():
				Jumping = false
		else:
			extra_jump = false
			Player.velocity.y = Player.velocity_jump * Multiply * Player.extra_jump_boost
		if Player.is_on_ceiling():
			Jumping = false


func wallJump() -> void:
	"""
	Maneja el salto en pared (wall jump).
	⚠️ Existe un bug:
		Si el jugador salta al lado de la pared pero estando en el piso, se suma la potencia de los dos saltos
	"""
	if Player.inputJump():
		if Player.isOnWall():
			CountJump = Player.extra_jump
			Jumping = true
			wallDirection = Player.getShapeDireccion()
			Player.velocity.y = 0
	if Jumping:
		if wallDirection == 0:
			wallDirection = Player.getShapeDireccion()
		Player.setShapeRotation(-1 * wallDirection)
		if not Player.isOnWall():
			Player.velocity.y += Player.wall_jump_velocity
			Player.velocity.x = -1 * wallDirection * Player.runVelocity * 1.5
	else:
		wallDirection = 0

func CoyoteTime():
	## Maneja el tiempo de "coyote" (puede saltar poco después de dejar el suelo)
	if Player.is_on_floor():
		TimerCoyote.stop()
		InFloor = true
		IsInCoyoteTime = false
	elif TimerCoyote.is_stopped() and InFloor:
		TimerCoyote.start()
		InFloor = false
		IsInCoyoteTime = true


func _on_timer_coyote_timeout() -> void:
	IsInCoyoteTime = false
#endregion
