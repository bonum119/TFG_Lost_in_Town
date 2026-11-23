
extends CharacterBody2D

@export var speed: float = 180.0
@export var gravity: float = 980.0


func _physics_process(delta: float) -> void:

	# Movimiento horizontal
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed

	# Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	# Movimiento físico
	move_and_slide()
