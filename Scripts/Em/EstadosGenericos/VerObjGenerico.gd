extends State
class_name VerObjGenerico

func enter() -> void:
	padre.velocity.x = 0
	await get_tree().create_timer(2).timeout	
	if !padre.stunned && padre.estado_alerta == AlertManager.alertStatus.NORMAL && padre.state_now is not MuerteGenerica:
		padre.alert_manager.llamar_alerta(AlertManager.alertStatus.PRECAUCION)
		await get_tree().create_timer(0.5).timeout
		padre.alert_manager.llamar_alerta(AlertManager.alertStatus.ALERTA)
		var estado_transicionar:String
		for i in get_child_count():
				if get_child(i) is RangoAtaqueGenerico:
					estado_transicionar = get_child(i).name
					break
		Transiciono.emit(padre.state_now, estado_transicionar)
