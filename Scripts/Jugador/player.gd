extends CharacterBody2D

func prueba1() -> bool:
	return Input.is_action_just_pressed("ui.left")

func prueba2() -> bool:
	return Input.is_action_just_pressed("ui.right")
