extends Node2D

"""
Nodo Dash:
	Función:
		Es el intermediario entre la máquina de estados del Dash y la máquina de estados central (u otras).
		La idea es tener un nodo "puente" que controle la comunicación y seguridad:
			- Quién cambia estados
			- Cómo interactúan
			- Qué variables se exponen
		Así, la máquina de Dash puede interactuar con Player u otros sin ensuciar lógica directamente.
"""

#region === Export variables ===
@export var DashNode:StateMachine          ## Referencia a la máquina de estados específica del Dash
@export var Player:CharacterBody2D         ## Referencia al jugador
@export var PlayerMachine:StateMachine ## Referencia a la máquina de estados central del personaje
@export var BulletTime:Node

@export var TiempoDeRecarga:float:         ## Tiempo de recarga del dash
	set(Var):
		TiempoDeRecarga = Var
		if not is_node_ready():
			await ready
		get_node("Timer Recarga").wait_time = Var

@export var TiempoDeDash:float:
	set(Var):
		TiempoDeDash = Var
		if not is_node_ready():
			await ready
		get_node("Timer Dash").wait_time = Var
@export var distancia_maxima:float
@export var Velocidad:float

#endregion


#region === Propiedades proxy ===
## Estas propiedades son "espejos" de las variables internas de DashNode
## Permiten acceder/modificar su valor desde este nodo intermediario.

var dasheando:bool:
	get():
		return DashNode.dasheando
	set(Var):
		DashNode.dasheando = Var

var ActualState:Array:
	get:
		return DashNode.ActualState
	set(Var):
		DashNode.ActualState = Var

var inicio_estado:bool:
	get:
		return DashNode.inicio_estado
	set(Var):
		DashNode.inicio_estado = Var
#endregion


#region === Métodos ===
func SetEstadoActual(Estado:String) -> void:
	"""
	Establece el estado actual de la máquina de Dash.
	En vez de llamar directamente al DashNode, se pasa por este nodo intermediario.
	"""
	DashNode.SetActualState(Estado)
#endregion
