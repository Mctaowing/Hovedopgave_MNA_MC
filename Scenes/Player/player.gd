extends CharacterBody2D

@onready var character_body_2d: CharacterBody2D = $"."

@export var speed = 200
@export var coordinates = position
var direction = "forward"
var health
var damage

var enemy_in_attack_range = false
var enemy_attack_cooldown = true
var player_alive = true


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = 200
	damage = 20

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	get_input()
	move_and_slide()
	updateDirection()
	updateAnimation()
	coordinates = character_body_2d.position
	enemy_attack()
	
	if health <= 0:
		player_alive = false ##Can add end screen or game over screen etc.
		health = 0
		print("player has been killed")
		self.queue_free()

func updateDirection():
	if velocity.x < 0: 
		direction = "sideway"
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0: 
		direction = "sideway"
		animated_sprite_2d.flip_h = false
	elif velocity.y < 0: 
		direction = "backward"
	elif velocity.y > 0:
		direction = "forward"

func updateAnimation():
	if velocity.length() == 0 && !animated_sprite_2d.is_playing():
		animated_sprite_2d.play("Idle_" + direction)
	elif velocity.length() > 0:
		animated_sprite_2d.play("Walk_" + direction)
	elif Input.is_action_just_pressed("attack") == true:
		animated_sprite_2d.play("Attack_" + direction)

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed


func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_attack_range = true


func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_attack_range = false

func enemy_attack():
	if enemy_in_attack_range and enemy_attack_cooldown == true:
		health = health - 10
		enemy_attack_cooldown = false
		$Attack_cooldown.start()
		print(health)

func player():
	pass


func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true
