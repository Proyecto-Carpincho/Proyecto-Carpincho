extends State
class_name EsperarGenerico

func enter() -> void:
	padre.nav.target_position = get_parent().global_position
	_esconder_en_llegada()

func physics_update(delta:float) -> void:
	padre._pathfind(delta, padre.speed)

func _esconder_en_llegada():
	await padre.nav.target_reached
	padre.hide()
