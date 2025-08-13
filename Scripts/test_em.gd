extends CentralEnemigo


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var nav:NavigationAgent2D = $NavigationAgent2D

func _physics_process(delta: float) -> void:
	var direction:Vector2
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	nav.target_position = Jugador.global_position
	
	direction = (nav.get_next_path_position() - global_position).normalized()
	print(direction)
	velocity = velocity.lerp(direction * SPEED, 5 * delta)
	
	move_and_slide()
