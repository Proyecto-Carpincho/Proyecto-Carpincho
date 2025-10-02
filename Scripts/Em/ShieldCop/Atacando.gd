extends State
class_name ShieldCopAtaque

@onready var padre:Enemigo = get_parent()

func physics_update(delta:float) -> void:
	var direction:Vector2
	if padre.dis_obj_ray.get_collider() != null:
		if padre.distancia_objetivo <= 600 && padre.dis_obj_ray.get_collider().is_class(padre.objetivo.get_class()):
			padre.nav.target_position = padre.objetivo.position
			direction = (padre.nav.get_next_path_position() - padre.global_position).normalized()
			padre.velocity = padre.velocity.lerp(direction * padre.SPEED, 5 * delta)
		else:
			Transiciono.emit(self, "ShieldCopChase")
