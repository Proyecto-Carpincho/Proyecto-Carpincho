extends CanvasLayer


func RelentizarTiempo(Tiempo:float,DetenerTiempo:bool=true) -> void:
	var RelTiemp:ColorRect = get_node("Relentizar tiempo")
	var ShaderTiem:ShaderMaterial = RelTiemp.material
	
	var Relentiza:int = 1 if DetenerTiempo else 0
	get_tree().create_tween().tween_property(ShaderTiem,"shader_parameter/Potencia",Relentiza,Tiempo)
