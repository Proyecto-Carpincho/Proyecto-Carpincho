extends Node
class_name StateTree

## Lista de nombres de estados que tienen lógica en _physics_process
@export var physicsStates: Array[String]

## Lista de nombres de estados que tienen lógica en _process
@export var processStates: Array[String]

## Devuelve true si el estado indicado está en la lista de estados de física
func HasPhysicsState(state: String) -> bool:
	return physicsStates.find(state) != -1

## Devuelve true si el estado indicado está en la lista de estados de proceso
func HasProcessState(state: String) -> bool:
	return processStates.find(state) != -1

## Método que debería ejecutar la lógica de _process para el estado actual
## (Es llamado por ExecutorStateTree._process si este StateTree contiene el estado activo)
func _ProcessMach(delta: float, state: String) -> void:
	pass

## Método que debería ejecutar la lógica de _physics_process para el estado actual
## (Es llamado por ExecutorStateTree._physics_process si este StateTree contiene el estado activo)
func _PhysicsMach(delta: float, state: String) -> void:
	pass
