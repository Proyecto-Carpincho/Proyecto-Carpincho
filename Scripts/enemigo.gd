extends CentralEnemigo


const SPEED = 300.0
const GravedadMax = 600

@onready var Navegacion:NavigationAgent2D = $NavigationAgent2D

func _physics_process(delta: float) -> void:
	var auxPathPosicion:Vector2=Navegacion.get_next_path_position()
	if global_position.direction_to(auxPathPosicion).length() < 5:
		global_position.x=move_toward(global_position.x, auxPathPosicion.x,delta*SPEED)
		if is_on_wall():
			global_position.y=move_toward(global_position.y, auxPathPosicion.y,delta*SPEED)
	else:
		velocity.x = global_position.direction_to(auxPathPosicion).x * SPEED
		if is_on_wall():
			velocity.y += global_position.direction_to(auxPathPosicion).y * SPEED
	
	
	
	var auxGravedad = get_gravity() if not is_on_wall_only() else Vector2.ZERO
	if not is_on_floor():
		if velocity.y + auxGravedad.y < GravedadMax:
			velocity.y += auxGravedad.y * delta
		else:
			velocity.y = GravedadMax
	move_and_slide()


func _process(_delta: float) -> void:
	if ComprobacionJugador() and EstaEnVision():
		if get_node("Timer").is_stopped():
			get_node("Timer").start()
	else:
		get_node("Timer").stop()

func ComprobacionJugador() -> bool:
	var Deteccion:Area2D = get_node("AreaDeteccion")
	return Deteccion.get_overlapping_bodies().find(Jugador) != -1



func _Timeout() -> void:
	Navegacion.target_position  = Jugador.global_position
