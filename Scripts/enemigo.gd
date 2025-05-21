extends CharacterBody2D


const SPEED = 300.0
@export var Personaje:CharacterBody2D
@onready var Navegacion:NavigationAgent2D = $NavigationAgent2D
var PosicionAir:Vector2

func _physics_process(delta: float) -> void:
	velocity = global_position.direction_to(Navegacion.get_next_path_position()) * SPEED
	move_and_slide()

func _AreaDeteccion_bodyEntered(body: Node2D) -> void:
	if Personaje == body:
		get_node("Timer").start()
		

func _AreaDeteccion_bodyExited(body: Node2D) -> void:
	if Personaje == body:
		get_node("Timer").stop()


func _Timeout() -> void:
	Navegacion.target_position = Personaje.global_position
