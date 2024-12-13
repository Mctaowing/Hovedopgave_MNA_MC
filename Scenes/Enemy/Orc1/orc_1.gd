class_name Orc1
extends "res://Scenes/Enemy/enemy.gd"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = "Orc1"
	health = 100
	speed = 100
	damage = 20
	spawn_coords = position
