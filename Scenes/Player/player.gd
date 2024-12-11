class_name Player
extends "res://Scenes/Being/being.gd"

@onready var character_body_2d: CharacterBody2D = $"."
@onready var interaction_manager = InteractionManager
@onready var gold_display = $Camera2D/Gold

var gold = 0
var enemy_in_attack_range = false
var enemy_attack_cooldown = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	direction = "forward"
	health = 200
	damage = 20
	speed = 200
	gold_display.text = "Gold: " + str(gold)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	get_input()
	move_and_slide()
	update_direction()
	update_animation()

func update_attack_area():
	if direction == "forward":
		attack_area_collision.transform = Transform2D(deg_to_rad(90), Vector2(1, 1), 0, Vector2(0, 22))
	elif direction == "backward":
		attack_area_collision.transform = Transform2D(deg_to_rad(90), Vector2(1, 1), 0, Vector2(0, 10))
	elif direction == "sideway":
		if sprite.flip_h == true:
			attack_area_collision.transform = Transform2D(0, Vector2(1.2, 0.8), 0, Vector2(-10, 18))
		else:
			attack_area_collision.transform = Transform2D(0, Vector2(1.2, 0.8), 0, Vector2(10, 18))

func update_animation():
	if velocity.length() == 0 && !sprite.is_playing():
		sprite.play("Idle_" + direction)
	elif velocity.length() > 0:
		sprite.play("Walk_" + direction)
	elif Input.is_action_just_pressed("attack")  == true:
		sprite.play("Attack_" + direction)
		attack()

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func update_gold(amount: int):
	gold += amount
	gold_display.text = "Gold: " + str(gold)
	
