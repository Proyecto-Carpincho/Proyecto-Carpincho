extends StateMachine

#region === Referencias a nodos del padre ===
@onready var line_dash:Line2D = get_parent().get_node("Line2D") ## Línea que indica dirección del dash 
@onready var line_viento:Line2D = get_parent().get_node("Line2D2") ## Línea que simula el efecto de line_viento durante el dash 
@onready var timer_dash:Timer = get_parent().get_node("Timer Dash") ## Timer que controla la duración del dash 
@onready var timer_recarga:Timer = get_parent().get_node("Timer Recarga") ## Timer que controla el cooldown antes de poder volver a hacer dash 
#endregion


#region === Variables de control ===
var mouse_position:Vector2      ## Posición del mouse relativa al jugador |
var global_mouse:Vector2        ## Posición global del mouse (con respecto a la escena) |

var dasheando:bool                 ## Indica si el jugador está actualmente en un dash |
var inicio_estado:bool           ## Marca si es el inicio del estado (primer frame en Dash) |
var primer_frame_dash:bool      ## True solo en el primer frame del dash |
var cambio_estado:bool            ## Marca si hubo un cambio de estado entre Dash/SinDash |
var estado_anterior:String       ## Guarda el estado anterior antes de entrar en Dash |
var activar_viento:bool          ## Flag usado para inicializar animación del line_viento |
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
			cambio_estado = true

			# Solo puede hacer dash si el timer de recarga terminó
			if timer_recarga.is_stopped():
				# Mostrar la línea de dirección al inicio
				if inicio_estado:
					line_dash.set_visible(true)

				# Actualizar la línea de dirección hacia el mouse
				if line_dash.is_visible():
					mouse_position = get_parent().get_local_mouse_position()
					#falopa de la dura
					mouse_position = mouse_position if mouse_position.length() < get_parent().distancia_maxima else mouse_position.normalized() * get_parent().distancia_maxima
					global_mouse = get_parent().to_global(mouse_position)
					line_dash.set_point_position(1, mouse_position)

				# Inicio del dash al presionar la tecla
				if Input.is_action_just_pressed("Dash") and not inicio_estado:
					# Asegura que el PlayerMachine cambie a un estado intermedio
					if get_parent().PlayerMachine.ActualState[0] != "Estado Intermedio":
						estado_anterior = get_parent().PlayerMachine.ActualState[0]
						get_parent().PlayerMachine.SetActualState("Estado Intermedio")
					activar_viento = true
					line_dash.set_visible(false)
					dasheando = true
					primer_frame_dash = true
					timer_dash.start()
					line_viento.set_visible(true)

				# Mientras esté en dash
				if dasheando:
					# Rotación según dirección X
					get_parent().Player.setShapeRotation(1 if mouse_position.normalized().x > 0 else -1)

					# Dirección hacia el mouse (limitada en Y para evitar dash muy verticales)
					var dir = mouse_position.normalized()
					dir.y = clamp(dir.y, -0.3, 0.3)
					dir = dir.normalized()

					# Velocidad objetivo del dash
					var target_velocity = dir * get_parent().Velocidad  

					# Movimiento interpolado hacia la velocidad objetivo
					var acceleration_factor = 0.2
					get_parent().Player.velocity = get_parent().Player.velocity.lerp(target_velocity, acceleration_factor)

					# Animación visual del line_viento
					MovimientoViento()

					# Conaciones de salida del dash
					if not primer_frame_dash and (
						timer_dash.is_stopped() 
						or get_parent().Player.global_position.distance_to(global_mouse) < 10 
						or get_parent().Player.global_position.distance_to(global_mouse) > get_parent().distancia_maxima * 1.3 
						or Input.is_action_pressed("Jump") 
						or get_parent().Player.isOnWall()
					):
						get_parent().Player.velocity *= 0.35 # Frenar al salir
						dasheando = false
						
						timer_recarga.start()
						Ui.RecargaDash(timer_recarga.wait_time)  # Llamada a UI
						SetActualState("SinDash")

				# Reset de banderas
				inicio_estado = false
				primer_frame_dash = false
			else:
				SetActualState("SinDash")
		#endregion


		#region --- Estado SIN DASH ---
		"SinDash":
			# Al salir del dash, restaurar el estado anterior
			if cambio_estado:
				cambio_estado = false
				get_parent().PlayerMachine.SetActualState(estado_anterior)
		#endregion
#endregion


#region === Animación de line_viento ===
func MovimientoViento():
	"""
	Actualiza la posición de las líneas del line_viento y 
	ejecuta animaciones de opacidad en el shader para dar efecto visual.
	"""
	var tamaño:float = get_parent().distancia_maxima
	line_viento.set_point_position(1, mouse_position.normalized() * tamaño)
	line_viento.set_point_position(0, (mouse_position * -1).normalized() * tamaño)

	if activar_viento:
		activar_viento = false
		var shader_viento:ShaderMaterial = line_viento.material
		shader_viento.set_shader_parameter("Alpha", 0.0)
		
		# Aparición progresiva
		await get_tree().create_timer(0.0005).timeout
		get_tree().create_tween().tween_property(shader_viento, "shader_parameter/Alpha", 1.0, 0.15)
		
		# Cambio de intensidad
		await get_tree().create_timer(0.2).timeout
		get_tree().create_tween().tween_property(shader_viento, "shader_parameter/Alpha", 2.0, 0.2)
#endregion
