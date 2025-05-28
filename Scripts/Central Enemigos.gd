extends CharacterBody2D
class_name CentralEnemigo

"""
Nodo central para los enemigos basicos todos los enemigos que busquen al el jugador y lo casen tendran que extenderse de esta clase
#ADVENTENCIA: No se puede usar como script si no como extencion
"""
@export var Jugador:CharacterBody2D
@export var FuerzaDeEmpuje:float = 10
var VelocidadEmpuje:Vector2
func EstaEnVision() -> bool:
	
	var RayVision:Node2D=get_node("VisionPersonaje")
	RayVision.rotation = RayVision.global_position.direction_to(Jugador.global_position).angle()
	
	for RayCast:RayCast2D in RayVision.get_children():
		if RayCast.get_collider() == Jugador:
			return true
	return false

func Golpeado(Angulo):
	VelocidadEmpuje = (Vector2.ZERO.from_angle(Angulo))* FuerzaDeEmpuje * Vector2(1,2)
	await get_tree().create_timer(0.4).timeout
	VelocidadEmpuje = Vector2(VelocidadEmpuje.x,0)
	await get_tree().create_timer(0.3).timeout
	VelocidadEmpuje = Vector2(0,0)
