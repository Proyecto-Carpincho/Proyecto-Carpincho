extends Node
class_name StateTree

@export var physicsStates: Array[String]
@export var processStates: Array[String]

func HasPhysicsState(state: String) -> bool:
	return physicsStates.find(state) != -1

func HasProcessState(state: String) -> bool:
	return processStates.find(state) != -1

func _ProcessMach(delta: float, state: String) -> void:
	pass

func _PhysicsMach(delta: float, state: String) -> void:
	pass
