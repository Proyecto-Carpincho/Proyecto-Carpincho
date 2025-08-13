extends Node
class_name StateMachine

##Todos los estados que estan en "_ProcessMatch()" que DEBERIA ser ejecutado por "_process()"
@export var ProcessStates:Dictionary[String,NodePath]
##Todos los estados que estan en "_PhysicsMatch()" que DEBERIA ser ejecutado por "_physics_process()"
@export var PhysicsStates:Dictionary[String,NodePath]
var ActualState:Array

#region Nombrar Funciones
func _ProcessMatch(delta:float,State:String) -> void:
	pass

func _PhysicsMatch(delta:float,State:String) -> void:
	pass
#endregion

##Para ejecutar process en la lista de _process. Solo llamarlo con la funcion _process()
func ExecuteProcess(delta:float)->void:
	if not ActualState.is_empty():
		if ProcessStates.has(ActualState[0]):
			var node = get_node(ActualState[1])
			if node is StateMachine:
				node._ProcessMatch(delta,ActualState[0])

##Para ejecutar process en la lista de _physics_process. Solo llamerlo con la _physics_process()
func ExecutePhysics(delta:float)->void:
	if not ActualState.is_empty():
		if PhysicsStates.has(ActualState[0]):
			var node = get_node(ActualState[1])
			if node is StateMachine:
				node._PhysicsMatch(delta,ActualState[0])

##Funcion encargada de setear AcutalState con solo el nombre del estado.
##Si el nodo con el estado no es self entonces setea el AcutalState tambien (para los casos de estados modurares)
func SetActualState(State:String, ProcessExternalState:bool=false) -> void:
	if not (PhysicsStates.has(State) or ProcessStates.has(State)):
		push_error("This State (",State,") not exist in PhysicsStates or ProcessStates")
		return
	var node:Node = get_node(ProcessStates[State]) if ProcessStates.has(State) else get_node(PhysicsStates[State]) as StateMachine
	if node != self: #Para que no tenga llamas infinitas
		node.SetActualState(State)
	
	# Siempre setear el estado actual si el nodo es self o si se pidió procesar externamente
	if node == self or ProcessExternalState:
		ActualState = [State, ProcessStates[State]] if ProcessStates.has(State) else [State, PhysicsStates[State]]
