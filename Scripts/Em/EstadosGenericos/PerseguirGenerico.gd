extends State
class_name PerseguirGenerico


func enter():
	padre.animated_sprite.stop()

func physics_update(delta:float) -> void:
	if padre.vio_jugador == false:
		if padre.position.distance_to(padre.alert_manager.upc) > 5:
			padre.nav.target_position = padre.alert_manager.upc + _upc_nav()
			padre._pathfind(delta, padre.RUN_SPEED)
		else:
			padre.velocity.x = 0
	elif padre.vio_jugador == true:
		var estado_transicionar:String
		for i in get_child_count():
				if get_child(i) is RangoAtaqueGenerico:
					estado_transicionar = get_child(i).name
					break
		Transiciono.emit(self, estado_transicionar)

func _upc_nav() -> Vector2:
	if (padre.alert_manager.upc.x - padre.position.x) > 0:
		return Vector2(100, 0)
	elif (padre.alert_manager.upc.x - padre.position.x) < 0:
		return Vector2(-100, 0)
	else:
		return Vector2(0, 0)
