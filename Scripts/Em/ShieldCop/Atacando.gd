extends State
class_name RangoAtaqueGenerico

@export var distancia_para_perder:int
@onready var padre:Enemigo = get_parent()

func physics_update(delta:float) -> void:
	var direction:Vector2
	if padre.dis_obj_ray.get_collider() != null:
		if padre.distancia_objetivo <= distancia_para_perder && padre.dis_obj_ray.get_collider().is_class(padre.objetivo.get_class()):
			padre.nav.target_position = padre.objetivo.position
			direction = (padre.nav.get_next_path_position() - padre.global_position).normalized()
			padre.velocity = padre.velocity.lerp(direction * padre.run_speed, 5 * delta)
			if padre.velocity.x > 0:
				padre.girar(true)
			elif padre.velocity.x < 0:
				padre.girar(false)
			if !padre.animated_sprite.is_playing():
				padre.animated_sprite.play("run")
		else:
			Transiciono.emit(self, "PerseguirGenerico")
