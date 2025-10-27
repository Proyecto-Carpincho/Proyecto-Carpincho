extends Entidad
class_name Enemigo

const ATTACK_DAMAGE:int = 50
const RUN_SPEED:int = 60

@export var objetivo:Entidad
@export var alert_manager:AlertManager
@export var grupo:String
@export var estado_inicial:State
@export var ruta:Path2D

@onready var nav:NavigationAgent2D = $NavigationAgent2D
@onready var dis_obj_ray:RayCast2D = $DistanciaJugador
@onready var animated_sprite:AnimatedSprite2D = $AnimatedSprite2D

var estado_alerta:AlertManager.alertStatus
var vio_jugador:bool
var distancia_objetivo:int
var stunned:bool
var state_now:State
var states:Dictionary = {}

func _ready() -> void:
	add_to_group(grupo)
	vio_jugador = false
	stunned = false
	if objetivo == null:
		objetivo = Entidad.new()
		push_warning("El objetivo de ", self.name, " es nulo")
	if alert_manager == null:
		alert_manager = AlertManager.new()
		alert_manager.estado_alerta = alert_manager.alertStatus.NORMAL
		push_warning("El alert manager de ", self.name, " es nulo")
	if ruta == null:
		ruta = Path2D.new()
		ruta.curve = Curve2D.new()
		ruta.curve.add_point(Vector2(position.x, position.y))
		push_warning("La ruta de ", self.name, " es nula")
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.Transiciono.connect(transicion_hijo)
	if objetivo == null && alert_manager == null && grupo == null && estado_inicial == null && ruta == null:
		push_error("Todos los exports son nulos, es probable que el editor tenga que ser reiniciado")
	state_now = estado_inicial
	state_now.enter()

func _process(delta: float) -> void:
	if state_now is not MuerteGenerica:
		$DistanciaJugador.target_position = to_local(objetivo.position)
		distancia_objetivo = $DistanciaJugador.position.distance_to($DistanciaJugador.target_position)
		var auxVio = false
		for i in range(-35, 36):
			$Vision.target_position.y = i
			if $Vision.get_collider() == objetivo:
				ver_jugador()
				auxVio = true
		if !auxVio:
			vio_jugador = false
	if state_now:
		state_now.update(delta)

func _physics_process(delta: float) -> void:
	if state_now:
		state_now.physics_update(delta)
	
	# Siento que hay una manera mas eficiente de hacer esto
	if state_now is not MuerteGenerica:
		_animacion_y_rotar()
	
	move_and_slide()

func cambiar_alerta(estado:AlertManager.alertStatus):
	var estado_transicionar:String
	estado_alerta = estado
	match estado_alerta:
		AlertManager.alertStatus.NORMAL:
			for i in get_child_count():
				if get_child(i) is PatrullarGenerico:
					estado_transicionar = get_child(i).name
					$Vision.target_position.x /= 2
					break
		AlertManager.alertStatus.PRECAUCION:
			for i in get_child_count():
				if get_child(i) is PatrullarGenerico:
					estado_transicionar = get_child(i).name
					break
		AlertManager.alertStatus.EVACION:
			for i in get_child_count():
				if get_child(i) is PerseguirGenerico:
					estado_transicionar = get_child(i).name
					break
		AlertManager.alertStatus.ALERTA:
			for i in get_child_count():
				if get_child(i) is RangoAtaqueGenerico:
					estado_transicionar = get_child(i).name
					$Vision.target_position.x += $Vision.target_position.x
					break
	transicion_hijo(state_now, estado_transicionar)

func ver_jugador():
	vio_jugador = true
	
	match estado_alerta:
		AlertManager.alertStatus.PRECAUCION:
			alert_manager.llamar_alerta(AlertManager.alertStatus.ALERTA)
			return
		AlertManager.alertStatus.EVACION:
			alert_manager.llamar_alerta(AlertManager.alertStatus.ALERTA)
			return
		AlertManager.alertStatus.ALERTA:
			if $Vision.get_collider() == objetivo:
				alert_manager.actualizar_upc(objetivo.position)
			return
		AlertManager.alertStatus.NORMAL:
			var estado_transicionar:String
			for i in get_child_count():
				if get_child(i) is VerObjGenerico:
					estado_transicionar = get_child(i).name
					break
			transicion_hijo(state_now, estado_transicionar)

func transicion_hijo(state:State, new_state_name:String):
	if state_now is not MuerteGenerica:
		if state != state_now:
			return
		var new_state = states.get(new_state_name)
		
		if !new_state:
			push_warning("El estado al que ", self.name," quiere trancisionar es invalido y/o inexistente")
			return
		if state_now:
			state_now.exit()
		new_state.enter()
		state_now = new_state

func _girar(b:bool):
	# false = izquierda
	# true = derecha
	if (b == false && $Vison.target_position.x > 0) || (b == true && $Vision.target_position.x < 0):
		$Vision.target_position.x *= -1
		$DamagArea.position.x *= -1 # TODO: que funcione
		animated_sprite.play("turn")
		await animated_sprite.animation_finished
		animated_sprite.flip_h = b

func Golpeado(fuerza, agresor:Entidad) -> void:
	if alert_manager.estado_alerta != AlertManager.alertStatus.NORMAL:
		if !vio_jugador:
			_girar(!animated_sprite.flip_h)
			var estado_transicionar:String
			for i in get_child_count():
				if get_child(i) is VerObjGenerico:
					estado_transicionar = get_child(i).name
					break
			transicion_hijo(state_now, estado_transicionar)
		
		super.Golpeado(fuerza, agresor)
	else:
		life -= life
	
	if life <= 0:
		var estado_transicionar:String
		for i in get_child_count():
				if get_child(i) is MuerteGenerica:
					estado_transicionar = get_child(i).name
					break
		transicion_hijo(state_now, estado_transicionar)


func _pathfind(delta:float, speed_path:float) -> void:
	var direction:Vector2 = (nav.get_next_path_position() - global_position).normalized()
	velocity.x = lerp(velocity.x, direction.x * speed_path, 5 * delta)

func _check_damage(body: Node2D) -> void: # Creo que se va a tener que mover todo esto a un Animation algo
	if $DamagArea.monitoring:
		var auxSelf := self.get_class()
		if body is Entidad && body is not Enemigo: # TODO: esto no es ideal
			body.Golpeado(ATTACK_DAMAGE, self)
			$DamagArea.monitoring = false

func _animacion_y_rotar():
	if velocity.x > 0:
		_girar(true)
		if !animated_sprite.is_playing() || animated_sprite.animation == "idle":
			animated_sprite.play("run")
	elif velocity.x < 0:
		_girar(false)
		if !animated_sprite.is_playing() || animated_sprite.animation == "idle":
			animated_sprite.play("run")
	else:
		if !animated_sprite.is_playing() || animated_sprite.animation == "run":
			animated_sprite.play("idle")
