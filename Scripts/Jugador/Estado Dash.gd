extends StateMachine



func _PhysicsMatch(delta:float,State:String) -> void:
	match State:
		"Dash":
			print("a")
			if Input.is_action_just_pressed("Dash"):
				SetActualState("Quieto")
				print(ActualState)
