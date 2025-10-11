extends StateMachine

#region === Variables principales ===
@export var Player:CharacterBody2D = get_parent()   ## Nodo jugador
@export var HabilidadesModulares:Node

#endregion

#region constantes Estados
const ESTADO_QUIETO = "Quieto"
const ESTADO_CAMINAR = "Caminar"
const ESTADO_CAIDA = "Caida"
#endregion

#region === Ciclo de vida ===
func _ready() -> void:
	SetActualState("Quieto")

func _physics_process(delta: float) -> void:
	ExecutePhysics(delta)
#endregion

#region === Logica Boleana ===
func enPiso()->bool:
	return Player.is_on_floor()
#endregion


#region === Lógica de estados ===
func _PhysicsMatch(delta:float, State:String) -> void:
	## Actualiza la UI con el estado actual
	Ui.SetState(State)

	## Reset de rotación en estados básicos
	if State in ["Correr",ESTADO_QUIETO,ESTADO_CAMINAR,ESTADO_CAIDA]:
		Player.setShapeRotation()
		salto(delta)
		if State != "Correr" and not enPiso():
			SetActualState(ESTADO_CAIDA)
	
	match State:
		ESTADO_QUIETO:
			if enPiso():
				var velocidad:float = Player.velocity.x
				const desadeleracion:float = 250
				velocidad = move_toward(velocidad,0, delta * desadeleracion)
				
				Player.velocity.x = velocidad
				
				if Player.inputWalk() != 0:
					SetActualState(ESTADO_CAMINAR)
		ESTADO_CAMINAR:
			if enPiso():
				var velocidad = Player.walkVelocity
				var velocidad_max = Player.maxWalkVelocity
				MovimientoX(velocidad,velocidad_max,delta)
				
				if Player.inputWalk() == 0:
					SetActualState(ESTADO_QUIETO)
		ESTADO_CAIDA:
			var velocidad = Player.walkVelocity
			var velocidad_max = Player.maxWalkVelocity
			MovimientoX(velocidad,velocidad_max,delta,true)
			if enPiso():
				if Player.inputWalk() == 0:
					SetActualState(ESTADO_QUIETO)
				else:
					SetActualState(ESTADO_CAMINAR)
	
	if not saltando:
		gravedad(delta)
	HabilidadesModulares._process_modular(delta)
	
	Player.move_and_slide()

func gravedad(delta:float)-> void:
	if not enPiso():
		var velocidad_caida:float = Player.velocity.y 
		var gravedad_max = Player.maxGravity
		var gravedad = Player.gravity * (delta * 2)
		if Player.velocity.y + gravedad < gravedad_max:
			Player.velocity.y += gravedad 
		
		else:
			const mult_delta:float = 100
			Player.velocity.y = move_toward(velocidad_caida , gravedad_max,delta * mult_delta)

#terrible chorizo de datos no?
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
			var dirreccion_final:int = Player.inputWalk() if Player.inputWalk() != 0 else direccion
			const reduccion_velocidad:float = 150
			Player.velocity.x = move_toward(Player.velocity.x, velocidad_Max*dirreccion_final, delta * reduccion_velocidad)
			if abs(Player.velocity.x) > 1.5 * velocidad_Max:
				Player.velocity.x = move_toward(Player.velocity.x,velocidad_Max*dirreccion_final,delta * reduccion_velocidad * 10)
		
		var AtaqueNodo = get_parent().get_node("Modular ability").AtaqueNodo
		var dasheando:bool = AtaqueNodo.DashNode.dasheando if AtaqueNodo.DashNode else false
		if abs(Player.velocity.x) > 1.8 * velocidad_Max and not dasheando:
			var dirreccion_final:int = Player.inputWalk() if Player.inputWalk() != 0 else direccion
			Player.velocity.x = move_toward(Player.velocity.x,velocidad_Max*dirreccion_final,delta * 150 * 35)

var saltando:bool
var saltos_extras:int
func salto(delta:float,salto_minimo:float=0.3,boost_salto=1,Aumento:float = 5)->void:
	var fuerza_salto:float = Player.velocity_jump * boost_salto
	#if encargado de aplicar fuerza mientras mas tiempo este presionado la key "Jump"
	if saltando:
		Player.velocity.y += (fuerza_salto * delta) * Aumento
		if (Player.velocity.y < Player.velocity_jump \
			or not Input.is_action_pressed("Jump") or enPiso()):
		
			saltando = false
	if enPiso():
		saltos_extras = Player.extra_jump
	
	#Verificacion salto
	var realizar_salto:bool
	if Input.is_action_just_pressed("Jump"):
		if enPiso():
			saltando = true
			realizar_salto = true
		
		elif saltos_extras != 0:
			saltos_extras -= 1
			saltando = true
			realizar_salto = true
	
	if realizar_salto:
		salto_minimo = abs(salto_minimo)
			
		Player.velocity.y = fuerza_salto*salto_minimo
#endregion
