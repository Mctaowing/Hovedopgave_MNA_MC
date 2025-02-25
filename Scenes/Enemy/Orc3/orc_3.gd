class_name Orc3
extends "res://Scenes/Enemy/enemy.gd"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = "Orc3"
	max_health = 200
	health = max_health
	health_bar.max_value = max_health
	speed = 100
	damage = 50
	dropped_exp = 15
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
			
func take_dmg(amount: int):
	print(str(self.get_type()) + " took " + str(amount) + " dmg.")
	health -= amount
	if health <= 0:
		player.update_exp(dropped_exp)
		death()

func _on_death_timeout() -> void:
	sprite.modulate.a -= 0.05
	if sprite.modulate.a <= 0:
		return
	$death.start()
