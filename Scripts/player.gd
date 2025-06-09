extends CharacterBody2D

@export var NodoDeAcciones:AccionNode
@export var arbolDeAnimaciones:AnimationTree
var SaltoExtra:int=1

var MaxGravedad=300
var VelocidadAcelerar=120
var VelocidadCaminar=150
var VelocidadCorrer=200

var MovimientoTotal:Vector2
var PosicionIDLE:Vector2
func _process(delta: float) -> void:
	InputJugador()

func InputJugador():
	MovimientoTotal = Input.get_vector("ui.left","ui.right","ui.down","ui.up")
	var estaQuieto:bool=MovimientoTotal.x == 0
	var estaCorriendo:bool=Input.is_action_pressed("run")
	PosicionIDLE = MovimientoTotal if MovimientoTotal != Vector2.ZERO else PosicionIDLE
	PosicionIDLE.y=0
	var NodoActual:String=arbolDeAnimaciones["parameters/playback"].get_current_node()
	NodoDeAcciones.ActivarTrancicion("Acelera",not estaQuieto)
	NodoDeAcciones.ActivarTrancicion("Desacelerar",estaQuieto)
	
	if not estaQuieto:
		NodoDeAcciones.ActivarTrancicion("Empieza A Correr",estaCorriendo)
		NodoDeAcciones.ActivarTrancicion("Empieza A Caminar",not estaCorriendo)
	
	if NodoActual in ["ACCELERATE","RUN","WALK"]:
		NodoDeAcciones.BlendPosicion(NodoActual,PosicionIDLE)
	NodoDeAcciones.BlendPosicion("IDLE",PosicionIDLE)

var MaxCorrer:float = 15000
var MaxCaminar:float = 8000

func _physics_processMatch(delta:float,NodoActual:String):
	match NodoActual:
		"IDLE":
			velocity.x = move_toward(velocity.x,0,delta*150)
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
	Salto(NodoActual,delta)
	move_and_slide()

var CantidadDeSaltoExtra:int=0
var VelocidadSalto:int=-1000
func Salto(NodoActual:String,delta):
	
	if NodoActual in ["ACCELERATE","RUN","WALK","IDLE"]:
		NodoDeAcciones.BlendPosicion(NodoActual,PosicionIDLE)
		if Input.is_action_just_pressed("ui.up"):
			if is_on_wall():
				velocity.y = -10000*delta*0.5
				CantidadDeSaltoExtra=0
			else:
				if is_on_floor():
					velocity.y = VelocidadSalto*3.5
					CantidadDeSaltoExtra=0
				elif CantidadDeSaltoExtra < SaltoExtra:
					velocity.y = VelocidadSalto*2.5
					CantidadDeSaltoExtra+=1
		
	if MovimientoTotal.y==0 and velocity.y < 0:
		velocity.y *=0.9
	var EstaEnPared= 1 if not is_on_wall() else 0.01
	if velocity.y > MaxGravedad:
		velocity.y=MaxGravedad*EstaEnPared
	else:
		velocity.y += get_gravity().y*delta*EstaEnPared
