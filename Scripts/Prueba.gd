extends StateMachine

func _ready() -> void:
	SetActualState("Test 0")

func _process(delta: float) -> void:
	ExecuteProcess(delta)

func _ProcessMatch(delta,State):
	match State:
		"Test 0":
			print("0")
			if get_parent().prueba1():
				SetActualState("Test 1")
			if get_parent().prueba2():
				SetActualState("Test 2")
		"Test 1":
			print("1")
			if get_parent().prueba2():
				SetActualState("Test 2")
		"Test 2":
			print("2")
			if get_parent().prueba1():
				SetActualState("Test 1")
