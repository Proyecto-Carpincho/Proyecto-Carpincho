extends Entidad
class_name Enemigo

@export var objetivo:Entidad
@export var alert_manager:AlertManager
@export var grupo:String
@export var run_speed:int
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
	state_now = estado_inicial

func _process(delta: float) -> void:
	$DistanciaJugador.target_position = to_local(objetivo.position)
	distancia_objetivo = position.distance_to($DistanciaJugador.target_position)
	var auxVio = false
	for i in 3:
		if $Vista.get_child(i).get_collider() == objetivo:
			ver_jugador()
			auxVio = true
	if !auxVio:
		vio_jugador = false
	if state_now:
		state_now.update(delta)

func _physics_process(delta: float) -> void:
	var direction:Vector2
	if not is_on_floor():
		velocity += get_gravity() * delta
	if state_now:
		state_now.physics_update(delta)
	move_and_slide()

func cambiar_alerta(estado:AlertManager.alertStatus):
	estado_alerta = estado
	match estado_alerta:
		AlertManager.alertStatus.NORMAL:
			transicion_hijo(state_now, "PatrullarGenerico")
		AlertManager.alertStatus.PRECAUCION:
			pass
		AlertManager.alertStatus.ALERTA:
			transicion_hijo(state_now, "RangoAtaqueGenerico")

func ver_jugador():
	vio_jugador = true
	
	match estado_alerta:
		AlertManager.alertStatus.PRECAUCION:
			alert_manager.llamar_alerta(AlertManager.alertStatus.ALERTA)
			return
			
		AlertManager.alertStatus.ALERTA:
			for i in 3:
				if $Vista.get_child(i).get_collider() == objetivo:
					alert_manager.actualizar_upc(objetivo.position)
			return
		AlertManager.alertStatus.NORMAL:
			await get_tree().create_timer(2).timeout	
			if !stunned && estado_alerta == AlertManager.alertStatus.NORMAL:
				alert_manager.llamar_alerta(AlertManager.alertStatus.PRECAUCION)
				await get_tree().create_timer(0.5).timeout
				alert_manager.llamar_alerta(AlertManager.alertStatus.ALERTA)

func transicion_hijo(state:State, new_state_name:String):
	if state != state_now:
		return
	var new_state = states.get(new_state_name)
	
	if !new_state:
		return
	if state_now:
		state_now.exit()
	new_state.enter()
	state_now = new_state

func girar(b:bool):
	for i in 3:
		if b == false && $Vista.get_child(i).target_position.x > 0:
			$Vista.get_child(i).target_position.x *= -1
			animated_sprite.play("turn")
		elif b == true && $Vista.get_child(i).target_position.x < 0:
			$Vista.get_child(i).target_position.x *= -1
			animated_sprite.play("turn")
			
	await animated_sprite.animation_finished
	animated_sprite.flip_h = b
