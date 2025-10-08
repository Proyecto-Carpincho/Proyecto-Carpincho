extends Enemigo
class_name ShieldCop

@export var cooldown_placaje:int

var cooldown_timer:float

func _ready() -> void:
	super._ready()
	cooldown_timer = 0

func _process(delta: float) -> void:
	super._process(delta)
	if cooldown_timer:
		cooldown_timer -= 1*delta

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func placaje_timer_crear() -> void:
	cooldown_timer = cooldown_placaje
