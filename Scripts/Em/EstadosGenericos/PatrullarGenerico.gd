extends State
class_name PatrullarGenerico

@onready var ruta:Path2D = get_parent().ruta

var cantidad_puntos
var progreso_ruta:int
var avanzando:bool


func enter() -> void:
	cantidad_puntos = ruta.curve.point_count
	progreso_ruta = 0
	for i in cantidad_puntos:
		if (ruta.curve.get_point_position(i) - padre.position) > (ruta.curve.get_point_position(progreso_ruta)  - padre.position):
			progreso_ruta = i
	
	if progreso_ruta < cantidad_puntos:
		avanzando = true

func physics_update(delta:float) -> void:
	padre.nav.target_position = ruta.curve.get_point_position(progreso_ruta)
	padre._pathfind(delta, padre.speed)
	
	if padre.position.distance_to(ruta.curve.get_point_position(progreso_ruta)) <= 10:
		if avanzando:
			if progreso_ruta < cantidad_puntos: # No entiendo porque cantidad_puntos es null pero esto no
				progreso_ruta += 1
			else:
				avanzando = false
		else:
			if progreso_ruta > 0:
				progreso_ruta -= 1
			else:
				avanzando = true
	
	if padre.velocity.x > 0:
			padre.girar(true)
	elif padre.velocity.x < 0:
			padre.girar(false)
	if !padre.animated_sprite.is_playing():
		padre.animated_sprite.play("walk")
