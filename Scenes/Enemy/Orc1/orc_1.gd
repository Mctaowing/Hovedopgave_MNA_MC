class_name Orc1
extends "res://Scenes/Enemy/enemy.gd"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = "Orc1"
	max_health = 100
	health = max_health
	health_bar.max_value = max_health
	speed = 100
	damage = 20
	spawn_coords = position

# Transform2D(rotation: deg_to_rad() float, scale: Vector2, skew: float, position: Vector2)
func update_attack_area():
	if direction == "forward":
		attack_area_collision.transform = Transform2D(deg_to_rad(90), Vector2(1, 1), 0, Vector2(0, 7))
	elif direction == "backward":
		attack_area_collision.transform = Transform2D(deg_to_rad(90), Vector2(1, 1), 0, Vector2(0, -9))
	elif direction == "sideway":
		if sprite.flip_h: #left
			attack_area_collision.transform = Transform2D(deg_to_rad(0), Vector2(1, 0.8), 0, Vector2(-17, 0))
		else: #right
			attack_area_collision.transform = Transform2D(deg_to_rad(0), Vector2(1, 0.8), 0, Vector2(15, 0))
