extends State
class_name BloqueoShieldCop

func enter() -> void:
	padre.velocity.x = 0
	padre.animated_sprite.play("block")
	await get_tree().create_timer(2).timeout
	var estado_transicionar:String
	if padre.estado_alerta == AlertManager.alertStatus.ALERTA:
		for i in get_child_count():
			if get_child(i) is RangoAtaqueGenerico:
				estado_transicionar = get_child(i).name
			break
	else:
		for i in get_child_count():
			if get_child(i) is VerObjGenerico:
				estado_transicionar = get_child(i).name
			break
	Transiciono.emit(self, estado_transicionar)
