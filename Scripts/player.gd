extends CharacterBody2D

@export var NodoDeAcciones:AccionNode
@export var arbolDeAnimaciones:AnimationTree

var Pr:bool=true
var MovimientoTotal:Vector2
var PosicionIDLE:Vector2
func _process(delta: float) -> void:
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
	MovimientoTotal = Input.get_vector("ui.left","ui.right","ui.down","ui.down")
