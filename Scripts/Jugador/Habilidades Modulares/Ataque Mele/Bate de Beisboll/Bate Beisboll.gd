extends ArmaMelee


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SetDataDash()
	get_node("Timer Congelacion").wait_time = TiempoDeCongelacion
	get_node("Timer Cooldown").wait_time = Cooldown
	get_node("Timer Fuerza").wait_time = TiempoAtaqueFuerte
