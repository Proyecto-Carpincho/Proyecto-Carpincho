extends Node2D
class_name AccionNode

"""
ACCION NODE:
	//FUNCION: Es un traductor para enviarle los datos al animation tree este"""

##AnimationTree con AnimationNodeStateMachine Dentro como esena principal
@export var arbolDeAnimaciones:AnimationTree

func ActivarTrancicion(NombredeTrancicion:String,Estado:bool):
	arbolDeAnimaciones["parameters/conditions/"+NombredeTrancicion] = Estado

func BlendPosicion(NombreDelBlend:String,Posicion:Variant):
	if typeof(Posicion) == TYPE_VECTOR2 or typeof(Posicion) == TYPE_FLOAT:
		if NombreDelBlend != "":
			arbolDeAnimaciones["parameters/"+NombreDelBlend+"/blend_position"] = Posicion
	else:
		push_error("El parametro \"Posicion\" no es ni float ni Vector2, TYPE = ", typeof(Posicion)," el nombre del blend es", NombreDelBlend)
		
