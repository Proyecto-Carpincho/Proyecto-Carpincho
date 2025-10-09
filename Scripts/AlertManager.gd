extends Node
class_name AlertManager

enum alertStatus{NORMAL, PRECAUCION, EVACION, ALERTA}

@export var grupo:String
@export var tiempo_maximo:int

var estado_alerta:alertStatus
var fuerza_alerta:int
var upc:Vector2 # Ultima posicion conocida
var temporizador:float

func _ready() -> void:
	fuerza_alerta = 0
	estado_alerta = alertStatus.NORMAL
	get_tree().call_group(grupo, "cambiar_alerta", estado_alerta)

func _process(delta: float) -> void:
	var cant_vee = 0 # La cantidad de enemigos que vio al objetivo
	if estado_alerta == alertStatus.ALERTA:
		for i in get_tree().get_node_count_in_group(grupo):
			if get_tree().get_nodes_in_group(grupo).get(i).state_now is RangoAtaqueGenerico:
				cant_vee += 1
		if cant_vee == 0:
			estado_alerta = alertStatus.EVACION
			get_tree().call_group(grupo, "cambiar_alerta", estado_alerta)
	
	if estado_alerta != alertStatus.ALERTA && estado_alerta != alertStatus.NORMAL:
		temporizador -= _distancia_objetivo()*delta
		if temporizador < 0:
			match estado_alerta:
				alertStatus.EVACION:
					estado_alerta = alertStatus.PRECAUCION
					get_tree().call_group(grupo, "cambiar_alerta", estado_alerta)
					temporizador = 99
				alertStatus.PRECAUCION:
					estado_alerta = alertStatus.NORMAL
					get_tree().call_group(grupo, "cambiar_alerta", estado_alerta)
	
	Ui.set_alert(estado_alerta)
	Ui.set_timer(temporizador)

func llamar_alerta(alerta:alertStatus) -> void:
	fuerza_alerta += alerta
	await get_tree().create_timer(0).timeout # Esperar a que mas de un enemigo haya visto al jugador
	if fuerza_alerta == 1:
		estado_alerta = alertStatus.PRECAUCION
		
	if fuerza_alerta >= 2:
		estado_alerta = alertStatus.ALERTA
	get_tree().call_group(grupo, "cambiar_alerta", estado_alerta)
	Ui.set_alert(estado_alerta)
	temporizador = 99

func actualizar_upc(pos:Vector2):
	upc = pos

func llamar_checkeo(em_position:Vector2) -> void:
	#TODO
	print("Checkeo llamado")

func _distancia_objetivo() -> int:
	if estado_alerta != alertStatus.EVACION:
		return 2
	
	var aux_average:int
	
	for i in get_tree().get_node_count_in_group(grupo):
			aux_average += get_tree().get_nodes_in_group(grupo).get(i).distancia_objetivo
	
	aux_average /= get_tree().get_node_count_in_group(grupo)
	
	return (aux_average*6)/100
