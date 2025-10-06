extends State
class_name PerseguirGenerico

@onready var padre:Enemigo = get_parent()

func enter():
	padre.animated_sprite.stop()

func physics_update(delta:float) -> void:
	var direction:Vector2
	
	if padre.vio_jugador == false:
		padre.nav.target_position = padre.alert_manager.upc
		direction = (padre.nav.get_next_path_position() - padre.global_position).normalized()
		padre.velocity = padre.velocity.lerp(direction * padre.run_speed, 5 * delta)
		if padre.velocity.x > 0:
			padre.girar(true)
		elif padre.velocity.x < 0:
			padre.girar(false)
		if !padre.animated_sprite.is_playing():
			padre.animated_sprite.play("run")
	elif padre.vio_jugador == true:
		Transiciono.emit(self, "RangoAtaqueGenerico")
