extends Node2D

@onready var Particula:GPUParticles2D = $GPUParticles2D
const velocidad=300
@export_range(-1,1) var DireccionHumo:float:
	set(Direccion):
		DireccionHumo = Direccion
		if Particula and Particula.process_material:
			Particula.process_material.directional_velocity_max=velocidad*Direccion
			Particula.process_material.directional_velocity_min=velocidad*Direccion

func _ready() -> void:
	DireccionHumo=DireccionHumo
