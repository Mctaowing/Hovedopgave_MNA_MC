extends "res://Scenes/Being/being.gd"

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var orc: CharacterBody2D = $"."

var player = null
var player_chase = false
var player_in_attack_zone = false
var can_take_damage = true

@export var coordinates = position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	coordinates = position
	direction = "forward"
	health = 100
	speed = 100
	damage = 20
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	move_and_slide()
	update_direction()
	update_animation()
	chasePlayer()
	deal_with_damage()

func update_direction():
	if abs(velocity.x) > abs(velocity.y):
		direction = "sideway"
		animated_sprite_2d.flip_h = velocity.x < 0
	elif velocity.y < 0: 
		direction = "backward"
	elif velocity.y > 0:
		direction = "forward"

func update_animation():
	if velocity.length() == 0 && !animated_sprite_2d.is_playing():
		animated_sprite_2d.play("Idle_" + direction)
	elif velocity.length() > 0:
		animated_sprite_2d.play("Walk_" + direction)
		
func chasePlayer():
	if player_chase:
		velocity = (player.position - position).normalized() * speed
	else:
		velocity = Vector2(0, 0)

func _on_area_2d_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false

func enemy():
	pass

func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_attack_zone = true

func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_attack_zone = false

func deal_with_damage():
	if player_in_attack_zone and global.player_current_attack == true:
		if can_take_damage == true:
			health = health - 20
			$Take_damage_cooldown.start()
			can_take_damage = false
			print("enemy health = ", health)
			if health <= 0:
				self.queue_free()

func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true
