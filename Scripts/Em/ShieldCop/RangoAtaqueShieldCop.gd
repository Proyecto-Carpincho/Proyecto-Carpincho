extends RangoAtaqueGenerico
class_name RangoAtaqueShieldCop


func physics_update(delta:float) -> void:
	super.physics_update(delta)
	if padre.dis_obj_ray.get_collider() != null:
		if padre.dis_obj_ray.get_collider().is_class(padre.objetivo.get_class()):
			if padre.distancia_objetivo <= 300 && padre.objetivo.position.y < padre.position.y + 75 && padre.objetivo.position.y > padre.position.y -75:
				Transiciono.emit(self, "PlacajeShieldCop")
			else:
				print(padre.distancia_objetivo)
