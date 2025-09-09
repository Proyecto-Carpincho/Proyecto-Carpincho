extends ArmaMelee


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SetDataDash()
	get_node("Timer Congelacion").wait_time = tiempo_congelacion
	get_node("Timer Cooldown").wait_time = cooldown
	get_node("Timer Fuerza").wait_time = tiempo_ataque_fuerte

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_up"):
		get_node("Timer Congelacion").wait_time = tiempo_congelacion
		get_node("Timer Cooldown").wait_time = cooldown
		get_node("Timer Fuerza").wait_time = tiempo_ataque_fuerte
	
