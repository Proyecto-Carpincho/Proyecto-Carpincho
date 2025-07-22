extends Node
class_name ExecutorStateTree

"""
Funcion:
	Cambia y Consigue el Nod Actual por transiciones del Animation Tree Seleccionado"""

##AnimationTree con AnimationNodeStateMachine Dentro como esena principal
@export var arbolDeAnimaciones:AnimationTree
@export var todosLosEstados:Dictionary[PackedStringArray,NodePath]:
	set(AllEstados):
		if not Engine.is_editor_hint():
			await ready
		todosLosEstados = AllEstados
		if arbolDeAnimaciones == null:
			push_error("esta maquina de estado no tiene asignado ningun animation tree")
			return
		else:
			for key in AllEstados.keys():
				for nodo in key:
					if not arbolDeAnimaciones.tree_root.get_node(nodo):
						push_error("El nodo \" ", nodo, "\" no existe en el Animation tree con el nombre \"", arbolDeAnimaciones.name, "\" ")
						return

func _process(delta: float) -> void:
	var NodoActual:String=ConseguirNodoActual()
	if NodoConAccion():
		for path in EncontrarTodosLosNodePath(NodoActual):
			var nodo:Node=get_node(path) 
			if nodo is StateTree:
				if nodo.HayEstadoDeProcess(NodoActual):
					nodo._ProcessMach(delta,NodoActual)
			else:
				push_error("Ese Nodo no es una Maquina de estado")

func _physics_process(delta: float) -> void:
	var NodoActual:String=ConseguirNodoActual()
	if NodoConAccion():
		for path in EncontrarTodosLosNodePath(NodoActual):
			var nodo:Node=get_node(path) 
			if nodo is StateTree:
				if nodo.HayEstadoDeFisica(NodoActual):
					nodo._PhysicsMach(delta,NodoActual)
			else:
				push_error("Ese Nodo no es una Maquina de estado")

func NodoConAccion() -> bool:
	var NodoActual:String=ConseguirNodoActual()
	for key in todosLosEstados.keys():
		for nodo in key:
			if nodo == NodoActual:
				return true
	return false

func EncontrarTodosLosNodePath(Nombre:String) -> PackedStringArray:
	var ListadePaths:Array[NodePath]
	
	for key:PackedStringArray in todosLosEstados.keys():
		for estado:String in key:
			if estado == Nombre and ListadePaths.find(todosLosEstados[key])==-1:
				ListadePaths.append(todosLosEstados[key])

	return ListadePaths

func ActivarTrancicion(NombredeTrancicion:String,Estado:bool):
	arbolDeAnimaciones["parameters/conditions/"+NombredeTrancicion] = Estado

func BlendPosicion(NombreDelBlend:String,Posicion:Variant):
	if typeof(Posicion) == TYPE_VECTOR2 or typeof(Posicion) == TYPE_FLOAT:
		if NombreDelBlend != "":
			arbolDeAnimaciones["parameters/"+NombreDelBlend+"/blend_position"] = Posicion
	else:
		push_error("El parametro \"Posicion\" no es ni float ni Vector2, TYPE = ", typeof(Posicion)," el nombre del blend es", NombreDelBlend)

func ConseguirNodoActual() -> String:
	return arbolDeAnimaciones["parameters/playback"].get_current_node()
