extends Node2D
class_name SpawnerEm

@export var alert_manager:AlertManager

var ultimo_estado:AlertManager.alertStatus

func _ready() -> void:
	for i in get_child_count():
		get_child(i).transicion_hijo(get_child(i).state_now, "EsperarGenerico")

func _process(delta: float) -> void:
	if alert_manager.estado_alerta != ultimo_estado:
		cambiar_alerta(alert_manager.estado_alerta)
	ultimo_estado = alert_manager.estado_alerta

func cambiar_alerta(estado:AlertManager.alertStatus) -> void:
	match estado:
			AlertManager.alertStatus.NORMAL:
				_regresar()
			AlertManager.alertStatus.ALERTA:
				_desplegar()

func _desplegar() -> void:
	for i in get_child_count():
		get_child(i).show()

func _regresar() -> void:
	for i in get_child_count():
		get_child(i).transicion_hijo(get_child(i).state_now, "EsperarGenerico")
