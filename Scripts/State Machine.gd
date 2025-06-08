extends Node2D
class_name StateMachine

##AnimationTree con AnimationNodeStateMachine Dentro como esena principal
@export var arbolDeAnimaciones:AnimationTree
var sinErrores:bool=true
@export var todosLosEstados:Dictionary[PackedStringArray,NodePath]:
	set(AllEstados):
		if not Engine.is_editor_hint():
			await ready
		todosLosEstados = AllEstados
		if arbolDeAnimaciones == null:
			push_error("esta maquina de estado no tiene asignado ningun animation tree")
			sinErrores = false
		else:
			for key in AllEstados.keys():
				for nodo in key:
					if not arbolDeAnimaciones.tree_root.get_node(nodo):
						push_error("El nodo \" ", nodo, "\" no existe en el Animation tree con el nombre \"", arbolDeAnimaciones.name, "\" ")
						sinErrores=false

func _process(delta: float) -> void:
	var NodoActual:String=arbolDeAnimaciones["parameters/playback"].get_current_node()
	if NodoConAccion():
		for path in EncontrarTodosLosNodePath(NodoActual):
			if get_node(path).has_method("_processMatch"):
				get_node(path)._processMatch(delta,NodoActual)

func _physics_process(delta: float) -> void:
	
	var NodoActual:String=arbolDeAnimaciones["parameters/playback"].get_current_node()
	if NodoConAccion():
		for path in EncontrarTodosLosNodePath(NodoActual):
			if get_node(path).has_method("_physics_processMatch"):
				get_node(path)._physics_processMatch(delta,NodoActual)

func NodoConAccion() -> bool:
	var NodoActual:String=arbolDeAnimaciones["parameters/playback"].get_current_node()
	for key in todosLosEstados.keys():
		for nodo in key:
			if nodo == NodoActual:
				return true
	return false

func EncontrarTodosLosNodePath(Nombre) -> PackedStringArray:
	var ListadePaths:Array[NodePath]
	
	for key in todosLosEstados.keys():
		for nodo in key:
			if nodo == Nombre and ListadePaths.find(todosLosEstados[key])==-1:
				ListadePaths.append(todosLosEstados[key])

	return ListadePaths
