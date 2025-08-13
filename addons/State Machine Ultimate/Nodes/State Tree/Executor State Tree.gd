extends Node 
class_name ExecutorStateTree

"""
Function:
	Changes and gets the current Node through transitions of the selected Animation Tree
	(Cambia y obtiene el nodo actual a través de transiciones del AnimationTree seleccionado)
"""

## AnimationTree con un AnimationNodeStateMachine como escena principal
@export var animationTree: AnimationTree

## Diccionario que relaciona conjuntos de estados (PackedStringArray) con NodePaths de StateTree asociados
@export var allStates: Dictionary[PackedStringArray, NodePath]:
	set(allStatesInput):
		# Si no está en modo editor, esperar a que el nodo esté listo antes de asignar
		if not Engine.is_editor_hint():
			await ready
		# Asignar el valor recibido a la variable interna
		allStates = allStatesInput
		# Si no hay AnimationTree asignado, mostrar error
		if animationTree == null:
			push_error("This state machine has no AnimationTree assigned")
			return
		else:
			# Validar que todos los nodos mencionados existan en el AnimationTree
			for key in allStatesInput.keys():
				for node in key:
					if not animationTree.tree_root.get_node(node):
						push_error("The node \" ", node, "\" does not exist in the AnimationTree named \"", animationTree.name, "\" ")
						return

func _process(delta: float) -> void:
	# Obtener el nodo actual del AnimationTree
	var auxCurrentNode: String = GetCurrentNode()
	# Solo continuar si el nodo actual está en la lista de estados con acciones
	if NodeHasAction():
		# Buscar todas las rutas de nodos que corresponden a ese estado
		for path in FindAllNodePaths(auxCurrentNode):
			var node: Node = get_node(path)
			# Si el nodo es un StateTree y tiene un estado de proceso que coincide, ejecutarlo
			if node is StateTree:
				if node.HasProcessState(auxCurrentNode):
					node._ProcessMach(delta, auxCurrentNode)
			else:
				push_error("This node is not a State Machine")

func _physics_process(delta: float) -> void:
	# Igual que _process pero usando lógica de física
	var auxCurrentNode: String = GetCurrentNode()
	if NodeHasAction():
		for path in FindAllNodePaths(auxCurrentNode):
			var node: Node = get_node(path)
			if node is StateTree:
				if node.HasPhysicsState(auxCurrentNode):
					node._PhysicsMach(delta, auxCurrentNode)
			else:
				push_error("This node is not a State Machine")

## Verifica si el nodo actual del AnimationTree está registrado como uno que tiene acción
func NodeHasAction() -> bool:
	var auxCurrentNode: String = GetCurrentNode()
	for key in allStates.keys():
		for node in key:
			if node == auxCurrentNode:
				return true
	return false

## Devuelve todas las rutas de nodos que contienen un estado con el nombre indicado
func FindAllNodePaths(name: String) -> PackedStringArray:
	var auxPathList: Array[NodePath]

	for key: PackedStringArray in allStates.keys():
		for state: String in key:
			# Si coincide el nombre y no está repetido, agregarlo
			if state == name and auxPathList.find(allStates[key]) == -1:
				auxPathList.append(allStates[key])

	return auxPathList

## Activa o desactiva una transición dentro del AnimationTree
func ActivateTransition(transitionName: String, state: bool):
	animationTree["parameters/conditions/" + transitionName] = state

## Cambia la posición de mezcla de un nodo de blend en el AnimationTree
func BlendPosition(blendName: String, position: Variant):
	# Solo aceptar valores Vector2 o float
	if typeof(position) == TYPE_VECTOR2 or typeof(position) == TYPE_FLOAT:
		if blendName != "":
			animationTree["parameters/" + blendName + "/blend_position"] = position
	else:
		push_error("The parameter \"position\" is neither float nor Vector2, TYPE = ", typeof(position), ", blend name is ", blendName)

# Devuelve el nombre del nodo actual que se está reproduciendo en el AnimationTree
func GetCurrentNode() -> String:
	return animationTree["parameters/playback"].get_current_node()
