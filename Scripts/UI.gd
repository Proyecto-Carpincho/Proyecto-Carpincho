extends CanvasLayer


func RecargaDash(TiempodeEspera:float = 0.4):
	var IconoMaterial:ShaderMaterial =get_node("Control/Panel/HBoxContainer/Icon").material
	IconoMaterial.set_shader_parameter("Tiempo",0.0)
	await get_tree().create_timer(0.1).timeout
	TiempodeEspera-=0.1
	get_tree().create_tween().tween_property(IconoMaterial,"shader_parameter/Tiempo",1.0,TiempodeEspera)

func SetState(state:String)->void:
	get_node("Control/Panel/RichTextLabel").text=state
