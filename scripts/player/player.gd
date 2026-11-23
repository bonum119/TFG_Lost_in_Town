
extends CharacterBody2D

@export var speed: float = 180.0
@export var gravity: float = 980.0
@export var jump_velocity: float = -400.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea

var facing_direction: String = "east"
var nearby_interactable: Area2D = null


func _ready() -> void:
	interaction_area.area_entered.connect(_on_area_entered)
	interaction_area.area_exited.connect(_on_area_exited)


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")

	velocity.x = direction * speed

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	update_animation(direction)

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if nearby_interactable != null:
			if nearby_interactable.has_method("interact"):
				nearby_interactable.interact()


func update_animation(direction: float) -> void:
	if direction > 0:
		facing_direction = "east"
	elif direction < 0:
		facing_direction = "west"

	var animation_name: String

	if direction != 0:
		animation_name = facing_direction + "_walk"
	else:
		animation_name = facing_direction + "_breathing"

	if sprite.animation != animation_name:
		sprite.play(animation_name)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactables"):
		nearby_interactable = area


func _on_area_exited(area: Area2D) -> void:
	if area == nearby_interactable:
		nearby_interactable = null
