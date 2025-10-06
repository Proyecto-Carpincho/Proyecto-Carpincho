extends State
class_name PatrullarGenerico

@onready var padre:Enemigo = get_parent()
@onready var ruta:Path2D = get_parent().ruta

func physics_update(delta:float) -> void:
	# TODO
	var direction:Vector2
	
	#padre.nav.target_position = ruta.curve.get
	direction = (padre.nav.get_next_path_position() - padre.global_position).normalized()
	padre.velocity = padre.velocity.lerp(direction * padre.speed, 5 * delta)
	if !padre.animated_sprite.is_playing():
		padre.animated_sprite.play("walk")
