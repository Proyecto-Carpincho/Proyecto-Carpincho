extends StateMachine

@onready var hitbox:CollisionShape2D = get_parent().get_node("Pivot Bate/Area2D/CollisionShape2D")
@onready var sprite:Sprite2D = get_parent().get_node("Pivot Bate/Sprite2D")
@onready var timer_fuerza:Timer = get_parent().get_node("Timer Fuerza")
@onready var timer_golpe:Timer = get_parent().get_node("Timer Golpe")
@onready var timer_congelacion:Timer = get_parent().get_node("Timer Congelacion")
@onready var pivot_bate:Node2D = get_parent().get_node("Pivot Bate")

var position_mouse:Vector2

func _physics_process(delta: float) -> void:
	ExecutePhysics(delta)

func _ready() -> void:
	SetActualState("Sin Ataque")

var FristFrame:bool
func _PhysicsMatch(delta:float, State:String) -> void:
	match State:
		"Ataque":
			inicio_ataque()
			print("ataque normal")
			hitbox.scale = Vector2.ONE 
			sprite.scale = Vector2(23,19)
			pivot_bate.rotation = position_mouse.angle()
		"Ataque Fuerte":
			inicio_ataque()
			print("ataque fuerte")
			
			hitbox.scale = Vector2.ONE * 1.4
			sprite.scale = Vector2(23,19) * 1.4
			pivot_bate.rotation = position_mouse.angle()
		"Manteniendo Ataque":
			if get_parent().get_node("Timer Cooldown").is_stopped():
				
				if timer_fuerza.is_stopped():
					timer_fuerza.start()
				
				if not Input.is_action_pressed("Ataque"):
					timer_fuerza.stop()
					FristFrame = true
					
					
					var mouse_pos = pivot_bate.get_global_mouse_position()
					position_mouse = mouse_pos - pivot_bate.global_position
					
					if EsAtaqueFuerte:
						timer_golpe.wait_time = get_parent().TiempoGolpeFuerte
						SetActualState("Ataque Fuerte")
					else:
						timer_golpe.wait_time = get_parent().TiempoGolpe
						SetActualState("Ataque")
			else:
				SetActualState("Sin Ataque")
		"Sin Ataque":
			EsAtaqueFuerte = false
			hitbox.disabled = true
			sprite.visible = false


var EsAtaqueFuerte:bool

func _TimerFuerza_Timeout() -> void:
	EsAtaqueFuerte  = true

func inicio_ataque() ->void:
	if FristFrame:
		timer_golpe.start()
	
	if timer_golpe.is_stopped():
		SetActualState("Sin Ataque")
		get_parent().get_node("Timer Cooldown").start()
	FristFrame = false
	hitbox.disabled = false
	sprite.visible = true


func _TimerCongelacion_Timeout() -> void:
	Engine.time_scale = 1
	EfectosVisuales.CongelarTiempo(false)


func _Area2D_bodyEntered(body: Node2D) -> void:
	if body.has_method("Golpeado"):
		# Si es un ataque fuerte entonces la fuerza es Fuerza * MultiplicadorFuerza o sea (Multi ataque fuerte) 
		# pero si no es un ataque fuerte entonces es solo Fuerza
		var Fuerza = get_parent().Fuerza if not EsAtaqueFuerte else get_parent().Fuerza * get_parent().MultiplicadorFuerza
		body.call("Golpeado", Fuerza , get_parent().Mata)
		if EsAtaqueFuerte:
			EfectosVisuales.CongelarTiempo()
			timer_congelacion.start()
			Engine.time_scale = 0
		SetActualState("Sin Ataque")
