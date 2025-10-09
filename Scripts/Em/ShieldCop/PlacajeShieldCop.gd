extends RangoAtaqueShieldCop
class_name PlacajeShieldCop

const velocidad_placaje = 250
var ultima_dir:int

func enter():
	padre.animated_sprite.play("placaje")
	if padre.velocity.x > 0:
		ultima_dir = velocidad_placaje
	elif padre.velocity.x < 0:
		ultima_dir = -velocidad_placaje
	else:
		Transiciono.emit(self, "RangoAtaqueShieldCop")

func physics_update(delta:float) -> void:
	#if padre.tocando_jugador(): TODO
	#	padre.objetivo.Golpeado(daño, 0)
	if padre.is_on_wall():
		padre.animated_sprite.play("stun")
		await get_tree().create_timer(1).timeout
		padre.animated_sprite.stop()
		padre.placaje_timer_crear()
		Transiciono.emit(self, "RangoAtaqueShieldCop")
	else:
		padre.velocity.x = ultima_dir
