extends CharacterBody2D

@export var NodoDeAcciones:AccionNode
@export var arbolDeAnimaciones:AnimationTree


var MaxGravedad=300
var VelocidadAcelerar=200
var VelocidadCaminar=150
var VelocidadCorrer=150

var Pr:bool=true
var MovimientoTotal:Vector2
var PosicionIDLE:Vector2
func _process(delta: float) -> void:
	InputJugador()

func InputJugador():
	MovimientoTotal = Input.get_vector("ui.left","ui.right","ui.down","ui.down")
	var estaQuieto:bool=MovimientoTotal.x == 0
	var estaCorriendo:bool=Input.is_action_pressed("run")
	PosicionIDLE = MovimientoTotal if MovimientoTotal != Vector2.ZERO else PosicionIDLE
	var NodoActual:String=arbolDeAnimaciones["parameters/playback"].get_current_node()
	NodoDeAcciones.ActivarTrancicion("Acelera",not estaQuieto)
	NodoDeAcciones.ActivarTrancicion("Desacelerar",estaQuieto)
	
	if not estaQuieto:
		NodoDeAcciones.ActivarTrancicion("Empieza A Correr",estaCorriendo)
		NodoDeAcciones.ActivarTrancicion("Empieza A Caminar",not estaCorriendo)
	
	if NodoActual in ["ACCELERATE","RUN","WALK"]:
		NodoDeAcciones.BlendPosicion(NodoActual,PosicionIDLE)
		NodoDeAcciones.BlendPosicion("IDLE",PosicionIDLE)

var MaxCorrer:float = 10000
var MaxCaminar:float = 8000

func _physics_processMatch(delta:float,NodoActual:String):
	match NodoActual:
		"IDLE":
			velocity.x = move_toward(velocity.x,0,delta*100)
		"ACCELERATE":
			velocity.x = VelocidadAcelerar*MovimientoTotal.x*delta*50
		"RUN":
			
			if abs(velocity.x) > MaxCorrer*delta:
				velocity.x = MaxCorrer*MovimientoTotal.x*delta
			else:
				velocity.x += VelocidadCorrer*MovimientoTotal.x*delta
		"WALK":
			if abs(velocity.x)> MaxCaminar*delta:
				velocity.x = MaxCaminar*MovimientoTotal.x*delta
			else:
				velocity.x += VelocidadCaminar*MovimientoTotal.x*delta
	prints(velocity.x,MaxCorrer*MovimientoTotal.x*delta,MaxCaminar*MovimientoTotal.x*delta)
	velocity.y += get_gravity().y*delta
	if velocity.y > MaxGravedad:
		velocity.y=MaxGravedad
	move_and_slide()
