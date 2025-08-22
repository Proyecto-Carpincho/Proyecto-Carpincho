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
@export var CentralStateMachine:StateMachine ## Referencia a la máquina de estados central del personaje

@export var TiempoDeRecarga:float:         ## Tiempo de recarga del dash
	set(Var):
		TiempoDeRecarga = Var
		DashNode.TiempoDeRecarga = Var      ## Se propaga el valor hacia el nodo Dash interno
#endregion


#region === Propiedades proxy ===
## Estas propiedades son "espejos" de las variables internas de DashNode
## Permiten acceder/modificar su valor desde este nodo intermediario.

var EnDash:bool:
	get():
		return DashNode.EnDash
	set(Var):
		DashNode.EnDash = Var

var ActualState:Array:
	get:
		return DashNode.ActualState
	set(Var):
		DashNode.ActualState = Var

var InicioEstado:bool:
	get:
		return DashNode.InicioEstado
	set(Var):
		DashNode.InicioEstado = Var
#endregion


#region === Métodos ===
func SetEstadoActual(Estado:String) -> void:
	"""
	Establece el estado actual de la máquina de Dash.
	En vez de llamar directamente al DashNode, se pasa por este nodo intermediario.
	"""
	DashNode.SetActualState(Estado)
#endregion
