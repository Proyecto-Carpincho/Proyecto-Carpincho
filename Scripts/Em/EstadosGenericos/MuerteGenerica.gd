extends State
class_name MuerteGenerica

var timer_checkeo:float = 10.0
var llamo_checkeo:bool = false

func enter():
	padre.animated_sprite.play("dead")
	padre.velocity = Vector2(0, 0)
	padre.remove_child(padre.find_child("Vista", true))
	padre.remove_child(padre.find_child("DistanciaJugador", true))
	padre.remove_child(padre.find_child("NavigationAgent2D", true))
	padre.remove_child(padre.find_child("DamagArea", true))

func update(delta:float):
	timer_checkeo -= 1*delta
	if timer_checkeo <= 0 && llamo_checkeo == false:
		padre.alert_manager.llamar_checkeo(padre.position)
		llamo_checkeo = true
