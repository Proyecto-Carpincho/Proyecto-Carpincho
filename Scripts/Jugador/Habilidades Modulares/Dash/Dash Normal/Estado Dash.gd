extends StateMachine

#region === Referencias a nodos del padre ===
@onready var Line2d:Line2D = get_parent().get_node("Line2D") ## Línea que indica dirección del dash 
@onready var Viento:Line2D = get_parent().get_node("Line2D2") ## Línea que simula el efecto de viento durante el dash 
@onready var timerDash:Timer = get_parent().get_node("Timer Dash") ## Timer que controla la duración del dash 
@onready var timerRecarga:Timer = get_parent().get_node("Timer Recarga") ## Timer que controla el cooldown antes de poder volver a hacer dash 
#endregion


#region === Variables de control ===
var MousePosition:Vector2      ## Posición del mouse relativa al jugador |
var GlobalMouse:Vector2        ## Posición global del mouse (con respecto a la escena) |
var velocidadPostion:Vector2   ## (No usada aún, parece reservada para cálculos de velocidad futura) |

var EnDash:bool                 ## Indica si el jugador está actualmente en un dash |
var InicioEstado:bool           ## Marca si es el inicio del estado (primer frame en Dash) |
var PrimerFrameEnDash:bool      ## True solo en el primer frame del dash |
var CambioStado:bool            ## Marca si hubo un cambio de estado entre Dash/SinDash |
var EstadoAnterior:String       ## Guarda el estado anterior antes de entrar en Dash |
var ActivarViento:bool          ## Flag usado para inicializar animación del viento |
#endregion


#region === Procesos de física ===
func _physics_process(delta: float) -> void:
	""" 
	Loop principal de física.
	Se delega a ExecutePhysics (definido en la clase base StateMachine). 
	"""
	ExecutePhysics(delta)
#endregion


#region === Manejo de estados ===
func _PhysicsMatch(_delta: float, State: String) -> void:
	"""
	Dependiendo del estado actual (Dash o SinDash) 
	se ejecuta la lógica correspondiente.
	"""
	match State:

		#region --- Estado DASH ---
		"Dash":
			CambioStado = true

			# Solo puede hacer dash si el timer de recarga terminó
			if timerRecarga.is_stopped():
				# Mostrar la línea de dirección al inicio
				if InicioEstado:
					Line2d.set_visible(true)

				# Actualizar la línea de dirección hacia el mouse
				if Line2d.is_visible():
					MousePosition = get_parent().get_local_mouse_position()
					MousePosition = MousePosition if MousePosition.length() < get_parent().DistanciaMaxima else MousePosition.normalized() * get_parent().DistanciaMaxima
					GlobalMouse = get_parent().to_global(MousePosition)
					Line2d.set_point_position(1, MousePosition)

				# Inicio del dash al presionar la tecla
				if Input.is_action_just_pressed("Dash") and not InicioEstado:
					# Asegura que el PlayerMachine cambie a un estado intermedio
					if get_parent().PlayerMachine.ActualState[0] != "Estado Intermedio":
						EstadoAnterior = get_parent().PlayerMachine.ActualState[0]
						get_parent().PlayerMachine.SetActualState("Estado Intermedio")
					ActivarViento = true
					Line2d.set_visible(false)
					EnDash = true
					PrimerFrameEnDash = true
					timerDash.start()
					Viento.set_visible(true)

				# Mientras esté en dash
				if EnDash:
					# Rotación según dirección X
					get_parent().Player.setShapeRotation(1 if MousePosition.normalized().x > 0 else -1)

					# Dirección hacia el mouse (limitada en Y para evitar dash muy verticales)
					var dir = MousePosition.normalized()
					dir.y = clamp(dir.y, -0.3, 0.3)
					dir = dir.normalized()

					# Velocidad objetivo del dash
					var target_velocity = dir * get_parent().Velocidad  

					# Movimiento interpolado hacia la velocidad objetivo
					var acceleration_factor = 0.2
					get_parent().Player.velocity = get_parent().Player.velocity.lerp(target_velocity, acceleration_factor)

					# Animación visual del viento
					MovimientoViento()

					# Condiciones de salida del dash
					if not PrimerFrameEnDash and (
						timerDash.is_stopped() 
						or get_parent().Player.global_position.distance_to(GlobalMouse) < 10 
						or get_parent().Player.global_position.distance_to(GlobalMouse) > get_parent().DistanciaMaxima * 1.3 
						or Input.is_action_pressed("Jump") 
						or get_parent().Player.isOnWall()
					):
						get_parent().Player.velocity *= 0.3  # Frenar al salir
						EnDash = false
						
						timerRecarga.start()
						Ui.RecargaDash(timerRecarga.wait_time)  # Llamada a UI
						SetActualState("SinDash")

				# Reset de banderas
				InicioEstado = false
				PrimerFrameEnDash = false
		#endregion


		#region --- Estado SIN DASH ---
		"SinDash":
			# Al salir del dash, restaurar el estado anterior
			if CambioStado:
				CambioStado = false
				get_parent().PlayerMachine.SetActualState(EstadoAnterior)
		#endregion
#endregion


#region === Animación de viento ===
func MovimientoViento():
	"""
	Actualiza la posición de las líneas del viento y 
	ejecuta animaciones de opacidad en el shader para dar efecto visual.
	"""
	var Tamaño:float = get_parent().DistanciaMaxima
	Viento.set_point_position(1, MousePosition.normalized() * Tamaño)
	Viento.set_point_position(0, (MousePosition * -1).normalized() * Tamaño)

	if ActivarViento:
		ActivarViento = false
		var ShaderViento:ShaderMaterial = Viento.material
		ShaderViento.set_shader_parameter("Alpha", 0.0)
		
		# Aparición progresiva
		await get_tree().create_timer(0.0005).timeout
		get_tree().create_tween().tween_property(ShaderViento, "shader_parameter/Alpha", 1.0, 0.15)
		
		# Cambio de intensidad
		await get_tree().create_timer(0.2).timeout
		get_tree().create_tween().tween_property(ShaderViento, "shader_parameter/Alpha", 2.0, 0.2)
#endregion
