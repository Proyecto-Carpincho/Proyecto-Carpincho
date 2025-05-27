extends CharacterBody2D
class_name CentralEnemigo

"""
Nodo central para los enemigos basicos todos los enemigos que busquen al el jugador y lo casen tendran que extenderse de esta clase
#ADVENTENCIA: No se puede usar como script si no como extencion
"""
@export var Jugador:CharacterBody2D
func EstaEnVision() -> bool:
	
	var RayVision:RayCast2D=get_node("VisionPersonaje")
	
	RayVision.rotation = RayVision.global_position.direction_to(Jugador.global_position).angle()
	return RayVision.get_collider() == Jugador
