extends Node2D


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Ataque"):
		get_node("Area2D/CollisionShape2D").disabled=false
		get_node("Area2D").rotation = get_local_mouse_position().angle()
	else:
		get_node("Area2D/CollisionShape2D").disabled=true



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("Golpeado"):
		body.Golpeado(get_node("Area2D").rotation)a
