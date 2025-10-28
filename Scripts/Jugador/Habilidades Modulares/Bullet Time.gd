extends Node
@export var bullet_time_active:bool
@export var bullet_time_sec:float
@export var cooldown:float
@export_range(0,1) var scale_timer:float
@onready var timer_cooldown:Timer = get_node("Timer Cooldown")
@onready var timer_bulletTime:Timer = get_node("Timer Bullet Time")
@export var active_for_input:bool

var cooldown_active:bool
var active:bool
func _physics_process(_delta: float) -> void:
	if active_for_input:
		active = Input.is_action_just_pressed("Bullet Time")
	
	if active and not cooldown_active and bullet_time_active:
		
		EfectosVisuales.RelentizarTiempo(0.3)
		await get_tree().create_timer(0.15).timeout
		Engine.time_scale = scale_timer
		
		timer_bulletTime.wait_time = bullet_time_sec
		timer_bulletTime.start()


func _TimerCooldown_Timeout() -> void:
	cooldown_active = false


func _TimerBulletTime_Timeout() -> void:
	EfectosVisuales.RelentizarTiempo(1, false)
	Engine.time_scale = 1
	
	Ui.RecargaBulletTime(cooldown)
	
	if not active_for_input:
		active = false
	cooldown_active = true
	timer_cooldown.wait_time = cooldown
	timer_cooldown.start()
