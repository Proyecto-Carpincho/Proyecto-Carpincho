extends StateMachine

@onready var Player:CharacterBody2D = get_parent().Player

@onready var Line2d:Line2D =get_parent().get_node("Line2D")
@onready var Viento:Line2D =get_parent().get_node("Line2D2")
@onready var timerDash:Timer= get_parent().get_node("Timer Dash")
@onready var timerRecarga:Timer= get_parent().get_node("Timer Recarga")

func _physics_process(delta: float) -> void:
	ExecutePhysics(delta)

var MousePosition:Vector2
var GlobalMouse:Vector2
var velocidadPostion:Vector2
var EnDash:bool
var InicioEstado:bool
var PrimerFrameEnDash:bool
var TiempoDeRecarga:float

func _PhysicsMatch(delta: float, State: String) -> void:
	match State:
		"Dash":
			if timerRecarga.is_stopped():
				if InicioEstado:
					Line2d.set_visible(true)

				if Line2d.is_visible():
					MousePosition = get_parent().get_local_mouse_position()
					MousePosition = MousePosition if MousePosition.length() < 150 else MousePosition.normalized() * 150
					GlobalMouse = get_parent().to_global(MousePosition)
					Line2d.set_point_position(1, MousePosition)

				if Input.is_action_just_pressed("Dash") and not InicioEstado:
					Test = true
					Line2d.set_visible(false)
					EnDash = true
					PrimerFrameEnDash = true
					timerDash.start()
					Viento.set_visible(true)

				if EnDash:
					# Rotación del sprite según dirección X
					Player.setShapeRotation(1 if MousePosition.normalized().x > 0 else -1)

					# Dirección hacia el mouse
					var dir = MousePosition.normalized()
					# Limitar componente Y para dash casi horizontal
					dir.y = clamp(dir.y, -0.3, 0.3)
					dir = dir.normalized()

					# Velocidad objetivo de dash
					var target_velocity = dir * 1250  # velocidad máxima de dash

					# Aceleración suave usando lerp
					var acceleration_factor = 0.2
					Player.velocity = Player.velocity.lerp(target_velocity, acceleration_factor)

					# Efectos de viento
					MovimientoViento()

					if not PrimerFrameEnDash and (timerDash.is_stopped() or Player.global_position.distance_to(GlobalMouse) < 10 \
						or Player.global_position.distance_to(GlobalMouse) > 200 or Input.is_action_pressed("Jump") or Player.isOnWall()):
						Player.velocity *= 0.3
						EnDash = false
						timerRecarga.wait_time = TiempoDeRecarga
						timerRecarga.start()
						Ui.RecargaDash(TiempoDeRecarga)
						SetActualState("SinDash")

				InicioEstado = false
				PrimerFrameEnDash = false


var Test:bool
func MovimientoViento():
	const Tamaño:float = 150
	Viento.set_point_position(1,MousePosition.normalized() * Tamaño)
	Viento.set_point_position(0,(MousePosition * -1).normalized() * Tamaño)
	if Test:
		Test = false
		var ShaderViento:ShaderMaterial = Viento.material
		ShaderViento.set_shader_parameter("Alpha",0.0)
		
		await get_tree().create_timer(0.0005).timeout
		get_tree().create_tween().tween_property(ShaderViento,"shader_parameter/Alpha",1.0,0.15)
		
		await get_tree().create_timer(0.2).timeout
		get_tree().create_tween().tween_property(ShaderViento,"shader_parameter/Alpha",2.0,0.2)
