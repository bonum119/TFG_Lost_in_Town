
extends CharacterBody2D

@export var speed: float = 180.0
@export var gravity: float = 980.0
@export var jump_velocity: float = -400.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Dirección inicial del personaje.
var facing_direction: String = "east"


func _physics_process(delta: float) -> void:

	# Movimiento horizontal.
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed

	# Gravedad.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Salto.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Actualizar animaciones.
	update_animation(direction)

	# Movimiento físico.
	move_and_slide()


func update_animation(direction: float) -> void:

	# Actualizar dirección.
	if direction > 0:
		facing_direction = "east"

	elif direction < 0:
		facing_direction = "west"

	# Elegir animación.
	if direction != 0:
		sprite.play(facing_direction + "_walk")

	else:
		sprite.play(facing_direction + "_breathing")
