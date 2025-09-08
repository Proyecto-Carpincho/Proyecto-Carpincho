extends CharacterBody2D

func _ready():
	pass

var velocidad = 200

func _process(delta):
	if Input.is_action_pressed("ui.right"):
		position.x += velocidad * delta
	if Input.is_action_pressed("ui.left"):
		position.x -= velocidad * delta
	if Input.is_action_pressed("ui.up"):
		position.y -= velocidad * delta
	if Input.is_action_pressed("ui.down"):
		position.y += velocidad * delta
