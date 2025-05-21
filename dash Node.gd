extends Node


var Dash:bool
var seDashActivo:bool
@onready var Padre:CharacterBody2D = get_parent()
@onready var ShapeCast:ShapeCast2D = get_node("ShapeCast2D")
var PosicionPreDash:Vector2
var VelociadMouse:Vector2

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("dash"):
		get_node("Timer").start()
		seDashActivo = true
	if Input.is_action_pressed("dash") and seDashActivo:
		ShapeCast.enabled = true
		PosicionLinea()
		EfectosVisuales.RelentizarTiempo(0.2)
		Engine.time_scale = 0.2
		if Input.is_action_just_pressed("Click"):
			StopTimer()
			var PositionMouse:Vector2 = Padre.get_global_mouse_position()
			DistanciaMouse = Padre.position.distance_to(PositionMouse)
			VelociadMouse = Padre.position.direction_to(PositionMouse).normalized() * 60000
			PosicionPreDash = Padre.global_position
			
			
			Dash = true
	else:
		var Line2DNode:Line2D= get_node("Line2D")
		Line2DNode.set_point_position(1,Vector2.ZERO)
		StopTimer()
	if Dash:
		EjecucionDash(delta)


var DistanciaMouse:float
func EjecucionDash(delta):
	Padre.velocity = VelociadMouse * delta
	
	var auxDistanciaMaxima = min(DistanciaMouse, 300)
	print(ShapeCast.get_collision_count())
	if PosicionPreDash.distance_to(Padre.global_position) > auxDistanciaMaxima or ShapeCast.get_collision_count() > 1:
		ShapeCast.enabled = false
		Dash = false
		Padre.velocity = VelociadMouse * delta / 2

func PosicionLinea():
	var Line2DNode:Line2D= get_node("Line2D")
	var MousePosition:Vector2= Padre.get_local_mouse_position() if Padre.get_local_mouse_position().length() < 300 else Padre.get_local_mouse_position().normalized()*300
	
	Line2DNode.set_point_position(1,MousePosition)
	ShapeCast.rotation = Padre.get_local_mouse_position().angle()
func StopTimer():
	EfectosVisuales.RelentizarTiempo(0.2,false)
	get_node("Timer").stop()
	Engine.time_scale = 1
	seDashActivo = false

func TimeoutFinTiempoBala() -> void:
	StopTimer()
