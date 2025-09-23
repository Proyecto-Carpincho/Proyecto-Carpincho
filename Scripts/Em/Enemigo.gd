extends Entidad
class_name Enemigo

@export var objetivo:Entidad
@export var alert_manager:AlertManager

func _ready() -> void:
	if objetivo == null:
		objetivo = Entidad.new()
	if alert_manager == null:
		alert_manager = AlertManager.new()
	#$RayCast2D.target = objetivo

func _process(delta: float) -> void:
	pass
