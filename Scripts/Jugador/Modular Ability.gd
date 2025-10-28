extends Node

@export var AtaqueNodo:ArmaMelee

func _process_modular(delta: float) -> void:
	
	if Input.is_action_just_pressed("Ataque"):
		AtaqueNodo.SetArmaState("Manteniendo Ataque")
	
	#endregion

	# Input Dash
	if Input.is_action_just_pressed("Dash") and (AtaqueNodo.DashNode.ActualState.find("Dash") == -1):
		AtaqueNodo.DashNode.inicio_estado = true
		AtaqueNodo.SetDashState("Dash")
