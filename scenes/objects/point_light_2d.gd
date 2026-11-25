extends PointLight2D

func _ready() -> void:
	# Esperamos un tiempo aleatorio al inicio para que las antorchas no vayan sincronizadas
	await get_tree().create_timer(randf_range(0.0, 1.0)).timeout
	ciclo_luz()

func ciclo_luz() -> void:
	var tween := create_tween()
	
	# 1 segundo subiendo la intensidad (entre 1.1 y 1.4)
	tween.tween_property(self, "energy", randf_range(1.1, 1.4), 1.0)
	
	# 1 segundo bajando la intensidad (entre 0.7 y 0.9)
	tween.tween_property(self, "energy", randf_range(0.7, 0.9), 1.0)
	
	# Cuando termina, vuelve a empezar con nuevos valores aleatorios
	tween.finished.connect(ciclo_luz)

	#Este codigo lo ha hecho la ia pero es muy sencillo de entender, cualquier duda me preguntais
