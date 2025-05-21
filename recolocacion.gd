extends Node2D


@onready var Padre:CharacterBody2D = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var ShapeCastCen:ShapeCast2D = get_node("ShapeCast Centro")
	var RayCastIz:RayCast2D = get_node("RayCast Izquierda")
	var RayCastDe:RayCast2D = get_node("RayCast Derecha")
	
	if ShapeCastCen.get_collision_count() > 2:
		if (RayCastIz.is_colliding() and not RayCastDe.is_colliding()) and Padre.EstaSaltando:
			Repocicionar(15)
		if (not RayCastIz.is_colliding() and RayCastDe.is_colliding()) and Padre.EstaSaltando:
			Repocicionar(-15)

func Repocicionar(nuevaPosicion: float) -> void:
	var destino = Padre.position.x + nuevaPosicion
	var tween = get_tree().create_tween()
	tween.tween_property(Padre, "position:x", destino, 0.1).set_ease(Tween.EASE_OUT)
