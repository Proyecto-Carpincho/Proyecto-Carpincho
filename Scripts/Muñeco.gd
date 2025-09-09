extends StaticBody2D


func _physics_process(delta: float) -> void:
	for label:Label in A:
		label.rotation = -rotation

func Golpeado(Fuerza,Mata,RotacionArea) -> void:
	var A = 1 if abs(RotacionArea) <= 90 else -1
	
	text(Fuerza)
	
	get_tree().create_tween().tween_property(self,"rotation_degrees",30* A,0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	await get_tree().create_timer(0.1).timeout
	get_tree().create_tween().tween_property(self,"rotation_degrees",-30*A,0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	await get_tree().create_timer(0.2).timeout
	get_tree().create_tween().tween_property(self,"rotation_degrees",0,0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
var A:Array[Label]
func text(Fuerza):
	var labelDaño:Label = get_node("Label").duplicate()
	add_child(labelDaño)
	A.append(labelDaño)
	labelDaño.set_visible(true)
	labelDaño.text = str(Fuerza)
	var time =0.9
	labelDaño.rotation = -rotation
	var final_position = Vector2(20,0) * randf_range(-1,1) - Vector2(25,10)
	get_tree().create_tween().tween_property(labelDaño,"position",final_position ,time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	get_tree().create_tween().tween_property(labelDaño,"scale",Vector2.ONE * 0.6,time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	await  get_tree().create_timer(time).timeout
	A.erase(labelDaño)
	labelDaño.queue_free()
