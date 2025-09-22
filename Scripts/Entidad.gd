extends CharacterBody2D
class_name Entidad

# Vida maxima de la entidad
@export var max_life:int
# Velocidad base de la entidad (esta se puede multiplicar)
@export var speed:float
# Cuantos golpes va a tomar antes de estar estuneado.
@export var max_stun_resistance:int

var life:int = max_life
var iframes:int = 0
var A:Array[Label]

func _process(delta: float) -> void:
	for label:Label in A:
		label.rotation = -rotation

func Golpeado(fuerza,mata) -> void:
	life -= fuerza
	text(fuerza)
	
func text(fuerza):
	var labelDaño:Label = get_node("Label").duplicate()
	add_child(labelDaño)
	A.append(labelDaño)
	labelDaño.set_visible(true)
	labelDaño.text = str(fuerza)
	var time =0.9
	labelDaño.rotation = -rotation
	var final_position = Vector2(20,0) * randf_range(-1,1) - Vector2(25,10)
	get_tree().create_tween().tween_property(labelDaño,"position",final_position ,time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	get_tree().create_tween().tween_property(labelDaño,"scale",Vector2.ONE * 0.6,time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	await  get_tree().create_timer(time).timeout
	A.erase(labelDaño)
	labelDaño.queue_free()
