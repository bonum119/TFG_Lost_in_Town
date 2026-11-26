extends CharacterBody2D

@export var speed: float = 180.0
@export var gravity: float = 980.0
@export var jump_velocity: float = -400.0
@export var acceleration: float = 900.0
@export var friction: float = 1200.0
@export var air_acceleration: float = 600.0
@export var jump_cut_multiplier: float = 0.5
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.12

var jump_buffer_timer: float = 0.0
var coyote_timer: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var camera: Camera2D = $Camera2D

var facing_direction: String = "east"
var nearby_interactables: Array[Area2D] = []
var _pause_layer: CanvasLayer = null


func _ready() -> void:
	interaction_area.area_entered.connect(_on_area_entered)
	interaction_area.area_exited.connect(_on_area_exited)


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	var target_speed := direction * speed

	if is_on_floor():
		if direction != 0:
			velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, friction * delta)
	else:
		velocity.x = move_toward(velocity.x, target_speed, air_acceleration * delta)

	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = jump_velocity
		coyote_timer = 0.0
		jump_buffer_timer = 0.0

	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier

	update_animation(direction)

	if Input.is_action_just_pressed("menu_pausa") and _pause_layer == null:
		_abrir_menu_pausa()

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		for area in nearby_interactables:
			if is_instance_valid(area) and area.has_method("interact"):
				area.interact()
				break


func update_animation(direction: float) -> void:
	if direction > 0.0:
		facing_direction = "east"
		sprite.flip_h = false #Volvemos a traer la animacion original
	elif direction < 0.0:
		facing_direction = "west"
		sprite.flip_h = true #Le damos la vuelta a la animacion para que mire al otro lado

	var animation_name: String
	if not is_on_floor() and sprite.sprite_frames.has_animation("jump"):
		animation_name = "jump"
	else:
		var base_anim := "east_walk" if direction != 0.0 else "east_breathing"
		animation_name = base_anim

	if sprite.animation != animation_name:
		sprite.play(animation_name)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactables"):
		if not nearby_interactables.has(area):
			nearby_interactables.append(area)

		var indicator = area.get_node_or_null("InteractionIndicator")
		if indicator:
			indicator.visible = true


func _on_area_exited(area: Area2D) -> void:
	if nearby_interactables.has(area):
		nearby_interactables.erase(area)

	var indicator = area.get_node_or_null("InteractionIndicator")
	if indicator:
		indicator.visible = false


func _abrir_menu_pausa() -> void:
	var menu_scene: PackedScene = load("res://scenes/ui/pause_menu.tscn")
	if menu_scene == null:
		return

	var interface_layer := CanvasLayer.new()
	interface_layer.process_mode = Node.PROCESS_MODE_ALWAYS

	var instantiate_menu := menu_scene.instantiate()
	instantiate_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	instantiate_menu.tree_exited.connect(_on_pause_menu_closed)

	interface_layer.add_child(instantiate_menu)
	get_tree().current_scene.add_child(interface_layer)
	_pause_layer = interface_layer

	get_tree().paused = true


func _on_pause_menu_closed() -> void:
	if is_instance_valid(_pause_layer):
		_pause_layer.queue_free()
	_pause_layer = null
	if is_inside_tree():
		get_tree().paused = false



func _process(_delta: float) -> void:
	camera.global_position.y = 0.0
