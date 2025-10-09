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
	#TODO: Mejorar
	if $WallCheck.is_colliding():
		if $WallCheck.get_collider() is TileMapLayer:
			velocity.y -= 10
	else:
		if not is_on_floor():
			velocity += get_gravity() * delta
	super._physics_process(delta)

func girar(b:bool) -> void:
	for i in 3:
		if (b == false && $Vista.get_child(i).target_position.x > 0) || (b == true && $Vista.get_child(i).target_position.x < 0):
			$Vista.get_child(i).target_position.x *= -1
			$WallCheck.target_position.x *= -1
			animated_sprite.play("turn")
	
	await animated_sprite.animation_finished
	animated_sprite.flip_h = b

func placaje_timer_crear() -> void:
	cooldown_timer = cooldown_placaje
