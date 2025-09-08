extends CanvasLayer


func RelentizarTiempo(Tiempo:float,DetenerTiempo:bool=true,ColorBorde:Color=Color(0.286, 0.0, 0.478),ColorFondo:Color=Color(0.51, 0.204, 0.463, 0.341)) -> void:
	var RelTiemp:ColorRect = get_node("Relentizar tiempo")
	var ShaderTiem:ShaderMaterial = RelTiemp.material
	ShaderTiem.set_shader_parameter("ColorDelBorde",ColorBorde)
	get_tree().create_tween().tween_property(ShaderTiem,"shader_parameter/ColorDelFondo",ColorFondo,Tiempo)
	var Relentiza:float = 0.3 if DetenerTiempo else 1.0
	get_tree().create_tween().tween_property(ShaderTiem,"shader_parameter/Bordeado",Relentiza,Tiempo)
	if not DetenerTiempo:
		get_tree().create_tween().tween_property(ShaderTiem,"shader_parameter/ColorDelFondo",Color(0.0, 0.0, 0.0, 0.0),Tiempo)
