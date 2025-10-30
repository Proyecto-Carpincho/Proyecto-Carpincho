extends RangoAtaqueShieldCop
class_name PlacajeShieldCop

const velocidad_placaje = 250
var ultima_dir:int

func enter():
	if padre.velocity.x > 0:
		padre._girar(true)
		ultima_dir = velocidad_placaje
	elif padre.velocity.x < 0:
		padre._girar(false)
		ultima_dir = -velocidad_placaje
	else:
		Transiciono.emit(self, "RangoAtaqueShieldCop")
	padre.animated_sprite.play("preparar_placaje")
	padre.velocity.x = 0
	await get_tree().create_timer(0.5).timeout
	if padre.state_now == self:
		padre.find_child("DamagArea").monitoring = true
		padre.animated_sprite.play("placaje")
		padre.velocity.x = ultima_dir

func physics_update(delta:float) -> void:
	if padre.is_on_wall():
		if (padre.find_child("WallCheck").get_collider() is Entidad) && !(padre.find_child("WallCheck").get_collider().is_in_group(padre.grupo)):
			if padre.find_child("DamagArea").monitoring:
				padre._check_damage(padre.find_child("WallCheck").get_collider())
			_volver_ataque()
		else:
			padre.velocity.x = -(padre.velocity.x/2)
			padre.velocity.y = -100
			_volver_ataque()
func _volver_ataque():
	padre.animated_sprite.play("stun")
	await get_tree().create_timer(2).timeout
	padre.animated_sprite.stop()
	padre.placaje_timer_crear()
	Transiciono.emit(self, "RangoAtaqueShieldCop")
