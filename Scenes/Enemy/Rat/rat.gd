class_name Rat
extends "res://Scenes/Enemy/enemy.gd"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = "Rat"
	health = 10
	damage = 2
	speed = 80
	spawn_coords = position

func update_direction():
	sprite.flip_h = velocity.x < 0

func update_animation():
	if alive:
		if velocity.length() == 0 && !sprite.is_playing():
			sprite.play("Idle")
		elif velocity.length() > 0:
			sprite.play("Run")
		elif attack_in_progress:
			sprite.play("Attack")
