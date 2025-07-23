extends Node
class_name StateMachine

##Todos los estados que estan en "_ProcessMatch()" que es ejecutado por "_process()"
@export var ProcessStates:Dictionary[String,NodePath]
##Todos los estados que estan en "_PhysicsMatch()" que es ejecutado por "_process()"
@export var PhysicsStates:Dictionary[String,NodePath]
var ActualState:Array

func _ProcessMatch(delta:float,State:String) -> void:
	pass

func _PhysicsMatch(delta:float,State:String) -> void:
	pass

func ExecuteProcess(delta:float)->void:
	if ProcessStates.has(ActualState[0]):
		if ActualState[1] is StateMachine:
			ActualState[1]._ProcessMatch(delta,ActualState[0])

func ExecutePhysics(delta:float)->void:
	if PhysicsStates.has(ActualState[0]):
		if ActualState[1] is StateMachine:
			ActualState[1]._PhysicsMatch(delta,ActualState[0])

func SetActualState(State:String) -> void:
	if not (PhysicsStates.has(State) or ProcessStates.has(State)):
		push_error("This State (",State,") not exist in PhysicsStates or ProcessStates")
		return
	
	ActualState=[State,ProcessStates.find_key(State)] if ProcessStates.has(State) else [State,PhysicsStates.find_key(State)]
