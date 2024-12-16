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

func take_dmg(amount: int):
	print(str(self.get_type()) + " took " + str(amount) + " dmg.")
	health -= amount
	if health <= 0:
		print(str(self.get_type()) + " died.")
		alive = false
		$CollisionShape2D.queue_free()
		$attack_area.queue_free()
		$tracking_area.queue_free()
		health_bar.queue_free()
		sprite.play("Death_" + direction)
		$death.start()
