extends CanvasLayer
var tweenBulletTime:Tween
var tweenDash:Tween

func RecargaBulletTime(TiempodeEspera:float = 0.4):
	var IconoMaterial:ShaderMaterial =get_node("SubViewportContainer/SubViewport/Control/Panel/HBoxContainer/Relentizar Tiempo/TextureRect").material
	IconoMaterial.set_shader_parameter("Tiempo",0.0)
	await get_tree().create_timer(0.1).timeout
	TiempodeEspera-=0.1
	if tweenBulletTime:
		tweenBulletTime.kill()
	tweenBulletTime = get_tree().create_tween()
	tweenBulletTime.tween_property(IconoMaterial,"shader_parameter/Tiempo",1.0,TiempodeEspera)

func RecargaDash(TiempodeEspera:float = 0.4):
	var IconoMaterial:ShaderMaterial =get_node("SubViewportContainer/SubViewport/Control/Panel/HBoxContainer/Dash/TextureRect").material
	if tweenDash:
		tweenDash.kill()
	
	IconoMaterial.set_shader_parameter("Tiempo",0.0)
	await get_tree().create_timer(0.1).timeout
	
	var n:float = TiempodeEspera
	TiempodeEspera-=0.1
	
		
	if n != 0:
		tweenDash = get_tree().create_tween()
		tweenDash.tween_property(IconoMaterial,"shader_parameter/Tiempo",1.0,TiempodeEspera)
	else:
		await get_tree().create_timer(0.1).timeout
		IconoMaterial.set_shader_parameter("Tiempo",1.0)

func SetState(state:String)->void:
	get_node("SubViewportContainer/SubViewport/Control/Panel/RichTextLabel").text=" Estado actual: "+state

func set_alert(state) -> void:
	$SubViewportContainer/SubViewport/Control/AlertaTemp/Estado.text = str(state)

func set_timer(tiempo:int):
	$SubViewportContainer/SubViewport/Control/AlertaTemp/Timer.text = str(tiempo)
