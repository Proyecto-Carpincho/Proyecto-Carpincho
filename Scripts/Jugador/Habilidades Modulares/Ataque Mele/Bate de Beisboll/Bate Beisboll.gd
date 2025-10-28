extends ArmaMelee


func _ready() -> void:
	SetDataDash()
	get_node("Timer Congelacion").wait_time = tiempo_congelacion
	get_node("Timer Cooldown").wait_time = cooldown
	get_node("Timer Fuerza").wait_time = tiempo_ataque_fuerte
