extends Node
class_name StateMachine

##Todos los estados que estan en "_ProcessMatch()" que es ejecutado por "_process()"
@export var ProcessStates:Dictionary[String,NodePath]
##Todos los estados que estan en "_PhysicsMatch()" que es ejecutado por "_process()"
@export var PhysicsStates:Dictionary[String,NodePath]
var ActualState:Array

func SetVelocity() -> void:
	if not ProcessStates.is_empty():
		var auxDic:Dictionary[String,NodePath]=ProcessStates.duplicate()
		ProcessStates.clear()
		for key:String in auxDic.keys():
			var path:NodePath=auxDic[key]
			if path != NodePath(""):
				ProcessStates.set(key,get_node(path).get_path())
	if not PhysicsStates.is_empty():
		var auxDic:Dictionary[String,NodePath]=PhysicsStates.duplicate()
		PhysicsStates.clear()
		for key:String in auxDic.keys():
			var path:NodePath=auxDic[key]
			if path != NodePath(""):
				PhysicsStates.set(key,get_node(path).get_path())

func _ProcessMatch(delta:float,State:String) -> void:
	pass

func _PhysicsMatch(delta:float,State:String) -> void:
	pass

func ExecuteProcess(delta:float)->void:
	if not ActualState.is_empty():
		if ProcessStates.has(ActualState[0]):
			var node = get_node(ActualState[1])
			if node is StateMachine:
				node._ProcessMatch(delta,ActualState[0])

func ExecutePhysics(delta:float)->void:
	if not ActualState.is_empty():
		if PhysicsStates.has(ActualState[0]):
			var node = get_node(ActualState[1])
			if node is StateMachine:
				node._PhysicsMatch(delta,ActualState[0])

func SetActualState(State:String) -> void:
	if not (PhysicsStates.has(State) or ProcessStates.has(State)):
		push_error("This State (",State,") not exist in PhysicsStates or ProcessStates")
		return
	var node:Node = get_node(ProcessStates[State]) if ProcessStates.has(State) else get_node(PhysicsStates[State]) as StateMachine
	if node != self: #Para que no tenga llamas infinitas
		node.SetActualState(State)
	ActualState = [State, ProcessStates[State]] if ProcessStates.has(State) else [State, PhysicsStates[State]]
