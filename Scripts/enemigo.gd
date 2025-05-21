extends CharacterBody2D


const SPEED = 300.0
const GravedadMax = 300
@export var Personaje:CharacterBody2D
@onready var Navegacion:NavigationAgent2D = $NavigationAgent2D
var PosicionAir:Vector2

func _physics_process(delta: float) -> void:
	if global_position.direction_to(Navegacion.get_next_path_position()).length() < 5:
		global_position.x=move_toward(global_position.x, Navegacion.get_next_path_position().x,delta*SPEED)
		global_position.y=move_toward(global_position.y, Navegacion.get_next_path_position().y,delta*SPEED)
	else:
		velocity.x = global_position.direction_to(Navegacion.get_next_path_position()).x * SPEED
		velocity.y += global_position.direction_to(Navegacion.get_next_path_position()).y * SPEED
	
	var auxGravedad = get_gravity() if not is_on_wall_only() else Vector2.ZERO
	if not is_on_floor():
		if velocity.y + auxGravedad.y < GravedadMax:
			velocity.y += auxGravedad.y * delta
		else:
			velocity.y = GravedadMax
	
	
	
	move_and_slide()

func _AreaDeteccion_bodyEntered(body: Node2D) -> void:
	if Personaje == body:
		get_node("Timer").start()
		

func _AreaDeteccion_bodyExited(body: Node2D) -> void:
	if Personaje == body:
		get_node("Timer").stop()


func _Timeout() -> void:
	Navegacion.target_position = Personaje.global_position
