@tool
extends Node2D
class_name StateMachine

##AnimationTree con AnimationNodeStateMachine Dentro como esena principal
@export var arbolDeAnimaciones:AnimationTree
@export var NodoDeAcciones:AccionNode
var sinErrores:bool=true
@export var todosLosEstados:Dictionary[String,NodePath]:
	set(AllEstados):
		todosLosEstados = AllEstados
		if not arbolDeAnimaciones:
			push_error("esta maquina de estado no tiene asignado ningun animation tree")
			sinErrores = false
		else:
			for key in AllEstados.keys():
				if not arbolDeAnimaciones.tree_root.get_node(key):
					push_error("El nodo \" ", key, "\" no existe en el Animation tree con el nombre \"", arbolDeAnimaciones.name, "\" ")
					sinErrores=false

func _ready() -> void:
	if sinErrores and arbolDeAnimaciones:
			NodoDeAcciones.TodosLosEstados = todosLosEstados.keys()
