extends CharacterBody2D

@export var NodoDeAcciones: AccionNode
@export var arbolDeAnimaciones: AnimationTree

var SaltoExtra: int = 1
var CantidadDeSaltoExtra: int = 0
var VelocidadSalto: int = -200

var MaxGravedad = 100000000000000
var VelocidadAcelerar = 120
var VelocidadCaminar = 150
var VelocidadCorrer = 200
var MaxCorrer: float = 15000
var MaxCaminar: float = 8000

var MovimientoTotal: Vector2
var PosicionIDLE: Vector2

func _process(delta: float) -> void:
	InputJugador()

func InputJugador():
	MovimientoTotal = Input.get_vector("ui.left", "ui.right", "ui.down", "ui.up")
	
	# Normalización entre -1 y 1
	if MovimientoTotal.x != 0:
		MovimientoTotal.x = 1 if MovimientoTotal.x > 0 else -1
	if MovimientoTotal.y != 0:
		MovimientoTotal.y = 1 if MovimientoTotal.y > 0 else -1

	var estaQuieto: bool = MovimientoTotal.x == 0
	var estaCorriendo: bool = Input.is_action_pressed("run")

	if MovimientoTotal != Vector2.ZERO:
		PosicionIDLE = MovimientoTotal
	PosicionIDLE.y = 0

	var NodoActual: String = arbolDeAnimaciones["parameters/playback"].get_current_node()

	#region Transiciones horizontales
	NodoDeAcciones.ActivarTrancicion("Acelera", not estaQuieto)
	NodoDeAcciones.ActivarTrancicion("Desacelerar", estaQuieto)
	if not estaQuieto:
		NodoDeAcciones.ActivarTrancicion("Empieza A Correr", estaCorriendo)
		NodoDeAcciones.ActivarTrancicion("Empieza A Caminar", not estaCorriendo)
	#endregion

	#region Transiciones verticales y estados
	NodoDeAcciones.ActivarTrancicion("Comienza a escalar", estaEnPared())
	NodoDeAcciones.ActivarTrancicion("Deja de Escalar", not estaEnPared())
	NodoDeAcciones.ActivarTrancicion("Parado",not Input.is_action_pressed("ui.up"))
	NodoDeAcciones.ActivarTrancicion("Subir", Input.is_action_pressed("ui.up"))
	NodoDeAcciones.ActivarTrancicion("Salto Pared", Input.is_action_just_pressed("Jump"))
	NodoDeAcciones.ActivarTrancicion("Esta en Piso", estaEnPiso())
	#endregion
	
	if NodoActual in ["ACCELERATE", "RUN", "WALK"]:
		NodoDeAcciones.BlendPosicion(NodoActual, PosicionIDLE)
	NodoDeAcciones.BlendPosicion("IDLE", PosicionIDLE)

func estaEnPiso() -> bool:
	return get_node("ShapeCast Comprobacion/Shape Piso").is_colliding()

func estaEnPared() -> bool:
	get_node("ShapeCast Comprobacion/Shape Pared").rotation = PosicionIDLE.angle()
	return get_node("ShapeCast Comprobacion/Shape Pared").is_colliding()

var PosicionPared:int

func _physics_processMatch(delta: float, NodoActual: String):
	match NodoActual:
		"IDLE":
			var Friccion = 150 if abs(velocity.x) < 50 else 300
			velocity.x = move_toward(velocity.x, 0, delta * Friccion)

		"ACCELERATE":
			if abs(velocity.x) < 5:
				velocity.x = VelocidadAcelerar * MovimientoTotal.x * delta * 50
			else:
				velocity.x = move_toward(velocity.x, 0, delta * 300)

		"RUN":
			if abs(velocity.x) > MaxCorrer * delta:
				velocity.x = MaxCorrer * MovimientoTotal.x * delta
			else:
				velocity.x += VelocidadCorrer * MovimientoTotal.x * delta

		"WALK":
			if abs(velocity.x) > MaxCaminar * delta:
				velocity.x = MaxCaminar * MovimientoTotal.x * delta
			else:
				velocity.x += VelocidadCaminar * MovimientoTotal.x * delta

		"CLIMB","CLIMB STOP":
			PosicionPared = PosicionIDLE.x
			if NodoActual == "CLIMB":
				if velocity.y > MaxCaminar * delta * 0.5:
					velocity.y = -MaxCaminar * delta * 0.5
				else:
					velocity.y -= MaxCaminar * delta * 0.2
		
		"WALL JUMP":
			if estaEnPared() and PosicionPared == PosicionIDLE.x:
				velocity = Vector2(PosicionPared,1) * VelocidadSalto
	print(NodoActual)
	Salto(NodoActual, delta)
	move_and_slide()

func Salto(NodoActual: String, delta):
	if NodoActual in ["ACCELERATE", "RUN", "WALK", "IDLE", "WALL JUMP"]:
		NodoDeAcciones.BlendPosicion(NodoActual, PosicionIDLE)
		if Input.is_action_just_pressed("Jump"):
			if estaEnPiso():
				velocity.y = VelocidadSalto * 3
				CantidadDeSaltoExtra = 0
			elif CantidadDeSaltoExtra < SaltoExtra:
				velocity.y = VelocidadSalto * 3
				CantidadDeSaltoExtra += 1
		if not Input.is_action_pressed("Jump") and velocity.y < 0:
			velocity.y *= 0.9
	
	var FuerzaCaida:float = 2 if not NodoActual in ["CLIMB","CLIMB STOP"] else 0.2
	if not estaEnPiso():
		if velocity.y > MaxGravedad * FuerzaCaida:
			velocity.y = MaxGravedad * FuerzaCaida
		else:
			velocity.y += get_gravity().y * delta * FuerzaCaida
