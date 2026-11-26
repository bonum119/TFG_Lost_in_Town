extends Sprite2D

@export var float_amplitude: float = 3.0
@export var float_speed: float = 3.0

var original_position: Vector2
var elapsed_time: float = 0.0


func _ready() -> void:
	original_position = position
	visible = false


func _process(delta: float) -> void:
	if not visible:
		return

	elapsed_time += delta

	position.y = original_position.y + sin(elapsed_time * float_speed) * float_amplitude
	
	
	#Creado tmb por IA, sirve para animar el ! de los objetos, si no lo entendeis me preguntais
