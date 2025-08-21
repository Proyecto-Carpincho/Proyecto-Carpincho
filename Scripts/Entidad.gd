extends CharacterBody2D
class_name Entidad

# Vida maxima de la entidad
@export var max_life:int
# Velocidad base de la entidad (esta se puede multiplicar)
@export var speed:float
# Cuantos golpes va a tomar antes de estar estuneado.
@export var max_stun_resistance:int

var life:int = max_life
var stun_resistance:int = max_stun_resistance
var iframes:int = 0

func _on_hit(damage:int, direction:float):
	if iframes == 0:
		life -= damage
		# TODO stun
	
