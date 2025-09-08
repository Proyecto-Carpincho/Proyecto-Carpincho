extends Node2D
class_name ArmaMelee

##El arma mata o solo noquea 
@export var Mata:bool
##Cantidad de daño que hace
@export var Fuerza:float
@export var Cooldown:float
##La duracion del golpe
@export var TiempoGolpe:float

@export_group("Ataque Fuerte")
@export var TieneAtaqueFuerte:bool
##El ataque fuerte es la fuerza del ataque normal multiplicado por un numero x
@export var MultiplicadorFuerza:float
@export var TiempoAtaqueFuerte:float
##Congela el tiempo el ataque fuerte cuando golpeas a alguien
@export var Congela:bool
@export var TiempoDeCongelacion:float
@export var TiempoGolpeFuerte:float

@export_group("Nodes")
@export_subgroup("Player")
@export var PlayerMachine:StateMachine
@export var Player:CharacterBody2D
@export_subgroup("Dash and Attack")
@export var ArmaStateMachine:StateMachine
@export var DashNode:Node2D

func SetArmaState(Estado:String) -> void:
	ArmaStateMachine.SetActualState(Estado)

func SetDashState(Estado:String) -> void:
	DashNode.SetEstadoActual(Estado)

func SetDataDash() -> void:
	DashNode.Player = Player
	DashNode.PlayerMachine = PlayerMachine
