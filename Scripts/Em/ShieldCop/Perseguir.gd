extends State
class_name ShieldCopChase

@onready var padre:Enemigo = get_parent()

func physics_update(delta:float) -> void:
	var direction:Vector2
	
	if padre.vio_jugador == false:
		padre.nav.target_position = padre.alert_manager.upc
		direction = (padre.nav.get_next_path_position() - padre.global_position).normalized()
		padre.velocity = padre.velocity.lerp(direction * padre.SPEED, 5 * delta)
	elif padre.vio_jugador == true:
		Transiciono.emit(self, "ShieldCopAtaque")
