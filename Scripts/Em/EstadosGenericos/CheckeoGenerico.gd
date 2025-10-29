extends State
class_name CheckeoGenerico

var vio:bool = false

func enter_check(em_posicion:Vector2) -> void:
	print("entro")
	padre.nav.target_position = em_posicion

func physics_update(delta:float) -> void:
	padre._pathfind(delta, padre.RUN_SPEED)
	
	if padre.find_child("Vision").get_collider() is Enemigo && padre.find_child("Vision").get_collider().is_in_group(padre.grupo):
		if !vio:
			padre.velocity.x = 0
			vio = true
			ver_em()
		

func ver_em() -> void:
	await get_tree().create_timer(1).timeout
	padre.alert_manager.llamar_alerta(AlertManager.alertStatus.PRECAUCION)
