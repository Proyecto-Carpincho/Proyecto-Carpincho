extends CentralEnemigo


const SPEED = 100
const GravedadMax = 200

@onready var Navegacion:NavigationAgent2D = $NavigationAgent2D

func _physics_process(delta: float) -> void:

	Moviminento()
	Gravedad(delta)
	Escudo()

	#Solo por ahora tiene esto que esta mal
	velocity.x += VelocidadEmpuje.x
	move_and_slide()

func Escudo():
	if velocity.x != 0:
		if velocity.x < 0 && $Escudo.global_position.x > 0:
			$Escudo.position.x = -30
		elif velocity.x > 0 && $Escudo.global_position.x < 0:
			$Escudo.position.x = 30
		 
	# TODO ¿Que hace "vistaPersonaje"? 
	
	"""RESPUESTA: la variable VistaPersonaje la variable de rotacion de un nodo que tiene raycast que revisa si el jugador esta siendo "visto" por los raycast
	 con eso hace que si mira hacia un lado y el jugador esta siendo visto por el enemigo revise si lo esta viendo a su izquierda o su derecha
	y vaya hacia la direccion de su vista
	Y la variable elEscudoVe no me acuerdo por que esta ahi y es totalmente inutil ahora"""
	
	#var elEscudoVe:int = 1 if get_node("Escudo").rotation == 0 else -1
	#var VistaPersonaje:int =1 if abs(get_node("VisionPersonaje").rotation) < 1.5 else -1
	#if velocity.normalized().x !=0:
		#if velocity.normalized().x < 0 and VistaPersonaje < 0:
			#$Escudo.position.x *= -1
		#elif VistaPersonaje > 0:
			#get_node("Escudo").rotation_degrees = 0

func Moviminento():
	
	var DistanciaAlJugador:float = Jugador.global_position.distance_to(global_position)
	Navegacion.target_position = Jugador.global_position
	var direccion:Vector2 = (Navegacion.get_next_path_position() - global_position).normalized()
	#Comprobacion Si esta o muy cerca o muy lejos del jugaodor para moverse (para que no paresca que este hujendole pues)
	if (DistanciaAlJugador < 78 or DistanciaAlJugador > 100) or get_node("Tiempo Recalcular Movimiento").is_stopped():
		velocity = direccion * SPEED
	else:
		velocity.x = 0.0
	if is_on_wall():
		#TODO agregar escalar muros
		velocity.y = 100
	else: 
		velocity.y = 0

func Gravedad(delta):
	var auxGravedad = get_gravity()
