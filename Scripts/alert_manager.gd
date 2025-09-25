extends Node
class_name AlertManager

enum alertStatus{NORMAL, PRECAUCION, ALERTA}

@export var grupo:String
@export var tiempo_maximo:int
var estado_alerta
var fuerza_alerta

func _ready() -> void:
	fuerza_alerta = 0
	estado_alerta = alertStatus.NORMAL
	get_tree().call_group(grupo, "cambiar_alerta", estado_alerta)

func _process(delta: float) -> void:
	pass

func llamar_alerta(alerta:alertStatus) -> void:
	fuerza_alerta += alerta
	await get_tree().create_timer(2).timeout # Esperar a que mas de un enemigo haya visto al jugador
	if fuerza_alerta == 1:
		estado_alerta = alertStatus.PRECAUCION
		
	if fuerza_alerta >= 2:
		estado_alerta = alertStatus.ALERTA
	Ui.set_alert(estado_alerta)
