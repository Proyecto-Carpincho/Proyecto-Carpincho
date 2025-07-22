extends Node
class_name StateTree

@export var EstadosDeFisicas:Array[String]
@export var EstadosDeProcess:Array[String]

func HayEstadoDeFisica(Estado:String) -> bool:
	return EstadosDeFisicas.find(Estado) != -1

func HayEstadoDeProcess(Estado:String) -> bool:
	return EstadosDeProcess.find(Estado) != -1

func _ProcessMach(delta:float,Estado:String) -> void:
	pass

func _PhysicsMach(delta:float,Estado:String) -> void:
	pass
