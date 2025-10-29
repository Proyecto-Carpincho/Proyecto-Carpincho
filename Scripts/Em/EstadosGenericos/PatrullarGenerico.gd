extends State
class_name PatrullarGenerico

@onready var ruta:RutaPatrullaje = get_parent().ruta

var loop:bool
var cantidad_puntos
var progreso_ruta:int
var avanzando:bool


func enter() -> void:
	loop = ruta.is_looping()
	cantidad_puntos = ruta.curve.point_count
	progreso_ruta = 0
	var ignorar_ultimo = 0
	if loop:
		ignorar_ultimo = 1
	for i in range(cantidad_puntos - ignorar_ultimo):
		if ruta.curve.get_point_position(i).distance_to(padre.position) < ruta.curve.get_point_position(progreso_ruta).distance_to(padre.position):
			progreso_ruta = i
	
	if progreso_ruta < cantidad_puntos:
		avanzando = true

func physics_update(delta:float) -> void:
	padre.nav.target_position = ruta.curve.get_point_position(progreso_ruta)
	
	padre._pathfind(delta, padre.speed)
	
	if padre.position.distance_to(ruta.curve.get_point_position(progreso_ruta)) <= 25:
		if avanzando:
			if (progreso_ruta < (cantidad_puntos - 1)):
				progreso_ruta += 1
			else:
				if !loop:
					avanzando = false
				else:
					progreso_ruta = 0
		elif !loop:
			if progreso_ruta > 0:
				progreso_ruta -= 1
			else:
				avanzando = true
