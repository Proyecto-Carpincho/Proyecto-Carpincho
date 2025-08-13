extends Node2D


"""
Nodo Dash:
	Funcion:
		Es el Intermediario entre la maquina de estados del Dash y La maquina de estados central o otras
		hago esto por seguridad y tener un camino donde se quien, que y como hacen cosas en la maquina de estados Dash.
		A y tambien para que la maquina de dash interactue con Player o otros"""

@export var DashNode:StateMachine
@export var Player:CharacterBody2D
@export var TiempoDeRecarga:float:
	set(Var):
		TiempoDeRecarga = Var
		DashNode.TiempoDeRecarga = Var

var EnDash:bool:
	get():
		return DashNode.EnDash
	set(Var):
		DashNode.EnDash = Var

var ActualState:Array:
	get:
		return DashNode.ActualState
	set(Var):
		DashNode.ActualState=Var

var InicioEstado:bool:
	get:
		return DashNode.InicioEstado
	set(Var):
		DashNode.InicioEstado=Var

func SetEstadoActual(Estado:String) -> void:
	DashNode.SetActualState(Estado)
