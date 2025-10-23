extends State
class_name BloqueoShieldCop

func enter() -> void:
	padre.velocity = Vector2(0,0)
	await get_tree().create_timer(2).timeout
	# Nose
