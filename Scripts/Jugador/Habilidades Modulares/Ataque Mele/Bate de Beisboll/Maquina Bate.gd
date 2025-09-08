extends StateMachine

@onready var HitBox:CollisionShape2D = get_parent().get_node("Pivot Bate/Area2D/CollisionShape2D")
@onready var Sprite:Sprite2D = get_parent().get_node("Pivot Bate/Sprite2D")
@onready var TimerFuerza:Timer = get_parent().get_node("Timer Fuerza")
@onready var TimerGolpe:Timer = get_parent().get_node("Timer Golpe")
@onready var PivotBate:Node2D = get_parent().get_node("Pivot Bate")
var PositionMouse:Vector2
func _physics_process(delta: float) -> void:
	ExecutePhysics(delta)

func _ready() -> void:
	SetActualState("Sin Ataque")

var FristFrame:bool
func _PhysicsMatch(delta:float, State:String) -> void:
	match State:
		"Ataque":
			InicioAtaque()
			
			HitBox.disabled = false
			Sprite.visible = true
			HitBox.scale = Vector2.ONE 
			Sprite.scale = Vector2(23,19)
			PivotBate.rotation = PositionMouse.angle()
		"Ataque Fuerte":
			InicioAtaque()
			
			HitBox.disabled = false
			Sprite.visible = true
			HitBox.scale = Vector2.ONE * 1.25
			Sprite.scale = Vector2(23,19) * 1.25
			PivotBate.rotation = PositionMouse.angle()
		"Manteniendo Ataque":
			if get_parent().get_node("Timer Cooldown").is_stopped():
				
				if TimerFuerza.is_stopped():
					TimerFuerza.start()
				
				if not Input.is_action_pressed("Ataque"):
					TimerFuerza.stop()
					FristFrame = true
					
					
					var mouse_pos = PivotBate.get_global_mouse_position()
					PositionMouse = mouse_pos - PivotBate.global_position
					
					if EsAtaqueFuerte:
						TimerGolpe.wait_time = get_parent().TiempoGolpeFuerte
						SetActualState("Ataque Fuerte")
					else:
						TimerGolpe.wait_time = get_parent().TiempoGolpe
						SetActualState("Ataque")
					EsAtaqueFuerte = false
			else:
				SetActualState("Sin Ataque")
		"Sin Ataque":
			HitBox.disabled = true
			Sprite.visible = false


var EsAtaqueFuerte:bool

func _TimerFuerza_Timeout() -> void:
	EsAtaqueFuerte  = true

func InicioAtaque() ->void:
	if FristFrame:
		TimerGolpe.start()
	
	if TimerGolpe.is_stopped():
		SetActualState("Sin Ataque")
		get_parent().get_node("Timer Cooldown").start()
	FristFrame = false


func _TimerCongelacion_Timeout() -> void:
	Engine.time_scale = 1
