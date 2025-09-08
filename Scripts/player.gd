extends CharacterBody2D

var jumpForce = -500
const velocidadMaxCaida = 600

var saltos_max = 2
var saltos = 0
var saltoInifinitos:bool

func _physics_process(delta):
	Salto(delta)
	Movimiento(delta)
	move_and_slide()
	
	if Input.is_action_just_pressed("ui.R") or position.y>= 400:
		reinicio()


var Culaso:bool
var seACulasado:bool
var EstaSaltando:bool
func Salto(delta):
	if not is_on_floor():
		saltos = saltos if saltos != 0 else 1
		saltos = 1 if is_on_wall() else saltos
		
		var velocidadCaida:float = get_gravity().y  * (delta * 2)
		
		#Si esta en una no pared la velocidad de caida es completa, si no es la mitad
		velocidadCaida = velocidadCaida if not is_on_wall() else velocidadCaida * 0.5
		#Si la no esta en una pared la gravedad maxima si no la gravedad maxima es solo un tercio
		var gravedadMaxima:float = velocidadMaxCaida if not is_on_wall() else velocidadMaxCaida * 0.3
		
		#Para que la velocidad de la gravedad no vallan a infinito
		if velocity.y < gravedadMaxima:
			velocity.y += velocidadCaida 
		#Se Comprueva que no por los caso que este haciendo un culaso, en ese caso va a otra velocidad
		elif not Culaso and not seACulasado:
			velocity.y = gravedadMaxima
		#Culaso
		Caida()
		
	else:
		seACulasado = false
		Culaso = false
		saltos = 0
		EstaSaltando = false
	if Input.is_action_just_pressed("ui_accept") and (saltos < saltos_max or saltoInifinitos):
		EstaSaltando = true
		velocity.y = jumpForce
		if not is_on_wall():
			saltos += 1
	


func Caida():
	if Input.is_action_pressed("ui.down") and not seACulasado:
		Culaso = true
		seACulasado = true
		if Culaso:
			Culaso = false
			velocity.y = velocidadMaxCaida * 1.2
			get_node("Timer Maxima Culaso").start()

func reinicio():
	velocity = Vector2.ZERO
	position = Vector2(0.0, -193.0)

const aceleracionMax = 500
const aceleracion = 200
const velocidadMax:float = 300


func Movimiento(delta):
	var Direccion:float = Input.get_axis("ui.left","ui.right")
	var auxDesaceleracion = 2000
	var auxAceleracion = ParametrosDeVelocidad(aceleracion,aceleracionMax)
	var auxVelocidadMax = ParametrosDeVelocidad(velocidadMax*0.6,velocidadMax)
	
	if Direccion == 0:
		
		velocity.x = move_toward(velocity.x,0,delta *auxDesaceleracion)
	else:
		var AceleracionFrame = auxAceleracion * Direccion
		if abs(velocity.x + AceleracionFrame * delta) <= auxVelocidadMax:
			velocity.x += AceleracionFrame * delta
		else:
			velocity.x = move_toward(velocity.x,AceleracionFrame,delta*10)

func ParametrosDeVelocidad(ParametroMin:float,ParametroMax:float, velocidadParaAcelerar:float = 0.6):
	var Acelerar:bool = Input.is_action_pressed("run")
	
	if (abs(velocity.x) > velocidadMax *velocidadParaAcelerar) and Acelerar:
		return ParametroMax 
	else:
		return ParametroMin



func _Timeout_MaximaCulaso() -> void:
	if not is_on_floor():
		velocity.y = velocidadMaxCaida * 2.5
