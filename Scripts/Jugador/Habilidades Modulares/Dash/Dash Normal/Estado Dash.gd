extends StateMachine

#region === Referencias a nodos del padre ===
@onready var dash_node:NormalDash = get_parent()
@onready var line_dash:Line2D = dash_node.get_node("Line2D") ## Línea que indica dirección del dash 
@onready var line_viento:Line2D = dash_node.get_node("Line2D2") ## Línea que simula el efecto de line_viento durante el dash 
@onready var timer_dash:Timer = dash_node.get_node("Timer Dash") ## Timer que controla la duración del dash 
@onready var timer_recarga:Timer = dash_node.get_node("Timer Recarga") ## Timer que controla el cooldown antes de poder volver a hacer dash 

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
					mouse_position = dash_node.get_local_mouse_position()
					#falopa de la dura
					mouse_position = mouse_position if mouse_position.length() < dash_node.distancia_maxima else mouse_position.normalized() * dash_node.distancia_maxima
					global_mouse = dash_node.to_global(mouse_position)
					line_dash.set_point_position(1, mouse_position)

				# Inicio del dash al presionar la tecla
				if Input.is_action_just_pressed("Dash") and not inicio_estado:
					# Asegura que el PlayerMachine cambie a un estado intermedio
					if dash_node.PlayerMachine.ActualState[0] != "Estado Intermedio":
						estado_anterior = dash_node.PlayerMachine.ActualState[0]
						dash_node.PlayerMachine.SetActualState("Estado Intermedio")
					activar_viento = true
					line_dash.set_visible(false)
					dasheando = true
					primer_frame_dash = true
					timer_dash.start()
					line_viento.set_visible(true)

				# Mientras esté en dash
				if dasheando:
					# Rotación según dirección X
					dash_node.Player.setShapeRotation(1 if mouse_position.normalized().x > 0 else -1)

					# Velocidad objetivo del dash
					var target_velocity =  mouse_position.normalized() * dash_node.Velocidad  

					# Movimiento interpolado hacia la velocidad objetivo
					var factor_aceleracion = 1 - dash_node.factor_aceleracion
					dash_node.Player.velocity = dash_node.Player.velocity.lerp(target_velocity, factor_aceleracion)
					# Animación visual del line_viento
					MovimientoViento()

					# Conaciones de salida del dash
					if not primer_frame_dash and (
						#termino el tiempo del dash
						timer_dash.is_stopped() 
						#o se encuentra al lado del punto que se queria ir
						or dash_node.Player.global_position.distance_to(global_mouse) < dash_node.distancia_maxima * 0.3
						#o se encuentra demaciado lejos de donde devia ir
						or dash_node.Player.global_position.distance_to(global_mouse) > dash_node.distancia_maxima * 1.3 
						#or Input.is_action_pressed("Jump") prueba de cancelacion de dash pero genera mas problemas de que soluciona
						#o se choco con una pared
						or dash_node.Player.isOnWall()
					):
						dash_node.Player.velocity *= dash_node.MultFrenado # Frenar al salir
						dasheando = false
						
						timer_recarga.start()
						Ui.RecargaDash(timer_recarga.wait_time)  # Llamada a UI para mostrar el tiempo que se tiene que recargar
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
				dash_node.PlayerMachine.SetActualState(estado_anterior)
		#endregion
#endregion


#region === Animación de line_viento ===
func MovimientoViento():
	"""
	Actualiza la posición de las líneas del line_viento y 
	ejecuta animaciones de opacidad en el shader para dar efecto visual.
	tiene problemas pero no tengo tiempo para solucionarlos
	"""
	var tamaño:float = dash_node.distancia_maxima
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
