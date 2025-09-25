extends Entidad
class_name Enemigo

@export var objetivo:Entidad
@export var alert_manager:AlertManager
@export var grupo:String

var estado_alerta:AlertManager.alertStatus
var vio_jugador:bool

func _ready() -> void:
	add_to_group(grupo)
	vio_jugador = false
	if objetivo == null:
		objetivo = Entidad.new()
	if alert_manager == null:
		alert_manager = AlertManager.new()
		alert_manager.estado_alerta = alert_manager.alertStatus.NORMAL

func _process(delta: float) -> void:
	for i in 3:
		if $Vista.get_child(i).get_collider() == objetivo:
			alert_manager.llamar_alerta(AlertManager.alertStatus.ALERTA)

func cambiar_alerta(estado:AlertManager.alertStatus):
	estado_alerta = estado
