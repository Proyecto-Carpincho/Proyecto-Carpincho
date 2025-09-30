extends Entidad
class_name Enemigo

@export var objetivo:Entidad
@export var alert_manager:AlertManager
@export var grupo:String
@export var SPEED:int

@onready var nav:NavigationAgent2D = $NavigationAgent2D
var estado_alerta:AlertManager.alertStatus
var vio_jugador:bool
var stunned:bool

func _ready() -> void:
	add_to_group(grupo)
	vio_jugador = false
	stunned = false
	if objetivo == null:
		objetivo = Entidad.new()
	if alert_manager == null:
		alert_manager = AlertManager.new()
		alert_manager.estado_alerta = alert_manager.alertStatus.NORMAL

func _process(delta: float) -> void:
	for i in 3:
		if $Vista.get_child(i).get_collider() == objetivo:
			ver_jugador()
		else:
			vio_jugador = false

func _physics_process(delta: float) -> void:
	var direction:Vector2
	if not is_on_floor():
		velocity += get_gravity() * delta
	match estado_alerta:
		1:
			pass
		2:
			if vio_jugador == true:
				nav.target_position = objetivo.position
			else:
				nav.target_position = alert_manager.upc
			direction = (nav.get_next_path_position() - global_position).normalized()
			if direction.x > global_position.x:
				scale.x = 1
			elif direction.x < global_position.x:
				scale.x = -1
			velocity = velocity.lerp(direction * SPEED, 5 * delta)
	move_and_slide()

func cambiar_alerta(estado:AlertManager.alertStatus):
	estado_alerta = estado
	if estado == 3:
		for i in 3:
			$Vista.get_child(i).target_position.x *= 2
			$Vista.get_child(i).target_position.y *= 2
	elif estado_alerta == AlertManager.alertStatus.PRECAUCION:
		for i in 3:
			$Vista.get_child(i).target_position.x /= 2
			$Vista.get_child(i).target_position.y /= 2
	estado_alerta = estado
	
func ver_jugador():
	# TODO limpiar
	vio_jugador = true
	if estado_alerta == AlertManager.alertStatus.PRECAUCION:
		alert_manager.llamar_alerta(AlertManager.alertStatus.ALERTA)
		return
	if estado_alerta == AlertManager.alertStatus.ALERTA:
		for i in 3:
			if $Vista.get_child(i).get_collider() == objetivo:
				alert_manager.actualizar_upc(objetivo.position)
		return
	await get_tree().create_timer(2).timeout
	if !stunned && estado_alerta == AlertManager.alertStatus.NORMAL:
		alert_manager.llamar_alerta(AlertManager.alertStatus.PRECAUCION)
		await get_tree().create_timer(0.5).timeout
		alert_manager.llamar_alerta(AlertManager.alertStatus.ALERTA)
		print("tmout")
