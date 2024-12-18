class_name Rat
extends "res://Scenes/Enemy/enemy.gd"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = "Rat"
	max_health = 30
	health = max_health
	health_bar.max_value = max_health
	damage = 10
	speed = 80
	spawn_coords = position

func update_direction():
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false
	update_attack_area()

func update_animation():
	if alive:
		if velocity.length() == 0 && !sprite.is_playing() && attack_in_progress == false:
			sprite.play("Idle")
		elif velocity.length() > 0:
			sprite.play("Run")
		elif atk_anim:
			sprite.play("Attack")
			atk_anim = false

# Transform2D(rotation: deg_to_rad() float, scale: Vector2, skew: float, position: Vector2)
func update_attack_area():
	if sprite.flip_h:
		attack_area_collision.transform = Transform2D(deg_to_rad(90), Vector2(1, 1), 0, Vector2(-10, 0))
	else:
		attack_area_collision.transform = Transform2D(deg_to_rad(90), Vector2(1, 1), 0, Vector2(10, 0))

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
		sprite.play("Death")
		$death.start()
