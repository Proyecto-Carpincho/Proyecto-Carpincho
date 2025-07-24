extends Node
class_name StateMachine

##Todos los estados que estan en "_ProcessMatch()" que es ejecutado por "_process()"
@export var ProcessStates:Dictionary[String,NodePath]
##Todos los estados que estan en "_PhysicsMatch()" que es ejecutado por "_process()"
@export var PhysicsStates:Dictionary[String,NodePath]
var ActualState:Array

func _ready() -> void:
	if not ProcessStates.is_empty():
		var auxDic:Dictionary[String,NodePath]=ProcessStates
		ProcessStates.clear()
		for key:String in auxDic.keys():
			var path:NodePath=auxDic[key]
			if path != NodePath(""):
				ProcessStates.set(key,get_node(path).get_path())
	if not PhysicsStates.is_empty():
		var auxDic:Dictionary[String,NodePath]=PhysicsStates
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
	if PhysicsStates.has(ActualState[0]):
		if ActualState[1] is StateMachine:
			var node = get_node(ActualState[1])
			if node is StateMachine:
				ActualState[1]._PhysicsMatch(delta,ActualState[0])

func SetActualState(State:String) -> void:
	if not (PhysicsStates.has(State) or ProcessStates.has(State)):
		push_error("This State (",State,") not exist in PhysicsStates or ProcessStates")
		return
	ActualState = [State, ProcessStates[State]] if ProcessStates.has(State) else [State, PhysicsStates[State]]
