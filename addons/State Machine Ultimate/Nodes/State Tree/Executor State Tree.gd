extends Node
class_name ExecutorStateTree

"""
Function:
	Changes and gets the current Node through transitions of the selected Animation Tree"""

##AnimationTree with AnimationNodeStateMachine as main scene
@export var animationTree: AnimationTree
@export var allStates: Dictionary[PackedStringArray, NodePath]:
	set(allStatesInput):
		if not Engine.is_editor_hint():
			await ready
		allStates = allStatesInput
		if animationTree == null:
			push_error("This state machine has no AnimationTree assigned")
			return
		else:
			for key in allStatesInput.keys():
				for node in key:
					if not animationTree.tree_root.get_node(node):
						push_error("The node \" ", node, "\" does not exist in the AnimationTree named \"", animationTree.name, "\" ")
						return

func _process(delta: float) -> void:
	var auxCurrentNode: String = GetCurrentNode()
	if NodeHasAction():
		for path in FindAllNodePaths(auxCurrentNode):
			var node: Node = get_node(path)
			if node is StateTree:
				if node.HasProcessState(auxCurrentNode):
					node._ProcessMach(delta, auxCurrentNode)
			else:
				push_error("This node is not a State Machine")

func _physics_process(delta: float) -> void:
	var auxCurrentNode: String = GetCurrentNode()
	if NodeHasAction():
		for path in FindAllNodePaths(auxCurrentNode):
			var node: Node = get_node(path)
			if node is StateTree:
				if node.HasPhysicsState(auxCurrentNode):
					node._PhysicsMach(delta, auxCurrentNode)
			else:
				push_error("This node is not a State Machine")

func NodeHasAction() -> bool:
	var auxCurrentNode: String = GetCurrentNode()
	for key in allStates.keys():
		for node in key:
			if node == auxCurrentNode:
				return true
	return false

func FindAllNodePaths(name: String) -> PackedStringArray:
	var auxPathList: Array[NodePath]

	for key: PackedStringArray in allStates.keys():
		for state: String in key:
			if state == name and auxPathList.find(allStates[key]) == -1:
				auxPathList.append(allStates[key])

	return auxPathList

func ActivateTransition(transitionName: String, state: bool):
	animationTree["parameters/conditions/" + transitionName] = state

func BlendPosition(blendName: String, position: Variant):
	if typeof(position) == TYPE_VECTOR2 or typeof(position) == TYPE_FLOAT:
		if blendName != "":
			animationTree["parameters/" + blendName + "/blend_position"] = position
	else:
		push_error("The parameter \"position\" is neither float nor Vector2, TYPE = ", typeof(position), ", blend name is ", blendName)

func GetCurrentNode() -> String:
	return animationTree["parameters/playback"].get_current_node()
