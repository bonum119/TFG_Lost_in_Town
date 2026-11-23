
extends Area2D


func _ready() -> void:
	add_to_group("interactables")


func interact() -> void:
	print("¡Has interactuado con el objeto!")
