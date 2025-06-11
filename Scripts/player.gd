extends CharacterBody2D

@export var NodoDeAcciones: AccionNode
@export var arbolDeAnimaciones: AnimationTree

var SaltoExtra: int = 1
var CantidadDeSaltoExtra: int = 0
var VelocidadSalto: int = -150

var MaxGravedad = 300
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

	# Transiciones horizontales
	NodoDeAcciones.ActivarTrancicion("Acelera", not estaQuieto)
	NodoDeAcciones.ActivarTrancicion("Desacelerar", estaQuieto)
	if not estaQuieto:
		NodoDeAcciones.ActivarTrancicion("Empieza A Correr", estaCorriendo)
		NodoDeAcciones.ActivarTrancicion("Empieza A Caminar", not estaCorriendo)

	# Transiciones verticales y estados
	NodoDeAcciones.ActivarTrancicion("Comienza a escalar", (is_on_wall()))
	NodoDeAcciones.ActivarTrancicion("Deja de Escalar", not is_on_wall())

	NodoDeAcciones.ActivarTrancicion("Salto en pared", Input.is_action_just_pressed("Jump"))
	NodoDeAcciones.ActivarTrancicion("Esta en Piso", is_on_floor())

	if NodoActual in ["ACCELERATE", "RUN", "WALK"]:
		NodoDeAcciones.BlendPosicion(NodoActual, PosicionIDLE)
	NodoDeAcciones.BlendPosicion("IDLE", PosicionIDLE)

func _physics_process(delta: float) -> void:
	var NodoActual: String = arbolDeAnimaciones["parameters/playback"].get_current_node()
	_physics_processMatch(delta, NodoActual)
	move_and_slide()

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

		"CLIMB":
			pass

	Salto(NodoActual, delta)

func Salto(NodoActual: String, delta):
	if NodoActual in ["ACCELERATE", "RUN", "WALK", "IDLE"]:
		NodoDeAcciones.BlendPosicion(NodoActual, PosicionIDLE)
		if Input.is_action_just_pressed("Jump"):
			if is_on_floor():
				velocity.y = VelocidadSalto * 3
				CantidadDeSaltoExtra = 0
			elif CantidadDeSaltoExtra < SaltoExtra:
				velocity.y = VelocidadSalto * 3
				CantidadDeSaltoExtra += 1
