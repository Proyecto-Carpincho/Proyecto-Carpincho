extends Node2D

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
