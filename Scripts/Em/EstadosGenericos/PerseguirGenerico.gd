extends State
class_name PerseguirGenerico


func enter():
	padre.animated_sprite.stop()

func physics_update(delta:float) -> void:
	if padre.vio_jugador == false:
		padre.nav.target_position = padre.alert_manager.upc# TODO hacer que avance despues de la ultima posicion conocida
		padre._pathfind(delta, padre.run_speed)
	elif padre.vio_jugador == true:
		var estado_transicionar:String
		for i in get_child_count():
				if get_child(i) is PatrullarGenerico:
					estado_transicionar = get_child(i).name
					break
		Transiciono.emit(self, estado_transicionar)
