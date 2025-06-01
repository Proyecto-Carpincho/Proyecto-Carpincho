extends CentralEnemigo


const SPEED = 100
const GravedadMax = 200

@onready var Navegacion:NavigationAgent2D = $NavigationAgent2D

func _physics_process(delta: float) -> void:
	
	Moviminento()
	Gravedad(delta)
	Escudo()

	#Solo por ahora tiene esto que esta mal
	velocity += VelocidadEmpuje
	move_and_slide()

func Escudo():
	var elEscudoVe:int = 1 if get_node("Escudo").rotation == 0 else -1
	var VistaPersonaje:int =1 if abs(get_node("VisionPersonaje").rotation) < 1.5 else -1
	if velocity.normalized().x !=0:
		if velocity.normalized().x < 0 and VistaPersonaje < 0:
			get_node("Escudo").rotation_degrees = 180
		elif VistaPersonaje > 0:
			get_node("Escudo").rotation_degrees = 0

func Moviminento():
	var auxPathPosicion:Vector2=Navegacion.get_next_path_position()
	var DistanciaAlJugador:float = Jugador.global_position.distance_to(global_position)
	#Comprobacion Si esta o muy cerca o muy lejos del jugaodor para moverse (para que no paresca que este hujendole pues)
	if (DistanciaAlJugador < 80 or DistanciaAlJugador > 100) or get_node("Tiempo Recalcular Movimiento").is_stopped():
		velocity.x = global_position.direction_to(auxPathPosicion).normalized().x * SPEED
	else:
		velocity.x = 0.0
	if is_on_wall():
		var VelocidadEscalar = global_position.direction_to(auxPathPosicion).normalized().y * SPEED 
		VelocidadEscalar = VelocidadEscalar if abs(VelocidadEscalar) > 50 else 50 * VelocidadEscalar/abs(VelocidadEscalar)
		velocity.y = VelocidadEscalar

func Gravedad(delta):
	var auxGravedad = get_gravity()
	if not is_on_floor() and not is_on_wall():
		if velocity.y + auxGravedad.y < GravedadMax:
			velocity.y += auxGravedad.y * delta
		else:
			velocity.y = GravedadMax



func _process(_delta: float) -> void:
	if ComprobacionJugador() and EstaEnVision():
		if get_node("Tiempo Recalcular Movimiento").is_stopped():
			get_node("Tiempo Recalcular Movimiento").start()
	elif get_node("Tiempo Perderlo de vista").is_stopped():
		get_node("Tiempo Perderlo de vista").start()

func ComprobacionJugador() -> bool:
	var Deteccion:Area2D = get_node("AreaDeteccion")
	return Deteccion.get_overlapping_bodies().find(Jugador) != -1



func _Timeout() -> void:
	
	var Posicion = Jugador.global_position
	if not (abs(Posicion.y - position.y) > 20):
		Posicion.x += -100 if Jugador.position.x - position.x > 0 else 100 
	Navegacion.target_position  = Posicion


func _Timout_PerderloVista() -> void:
	get_node("Tiempo Recalcular Movimiento").stop()
