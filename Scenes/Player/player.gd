class_name Player
extends CharacterBody2D

@onready var interaction_manager = InteractionManager
@onready var gold_display = $Camera2D/Gold
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area_collision: CollisionShape2D = $attack_area/CollisionShape2D

var type: String = "Player"
var direction: String
var health: int
var damage: int
var speed: int

var alive = true
var attack_in_progress = false
var enemies_in_attack_range = []
var gold = 0

func get_type():
	return type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = "Player"
	direction = "forward"
	health = 200
	damage = 20
	speed = 200
	gold_display.text = "Gold: " + str(gold)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if alive:
		get_input()
		move_and_slide()
		update_direction()
		update_animation()
	
func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func update_direction():
	if abs(velocity.x) > abs(velocity.y):
		direction = "sideway"
		sprite.flip_h = velocity.x < 0
	elif velocity.y < 0: 
		direction = "backward"
	elif velocity.y > 0:
		direction = "forward"
	update_attack_area()

func update_animation():
	if velocity.length() == 0 && !sprite.is_playing() && attack_in_progress == false:
		sprite.play("Idle_" + direction)
	elif velocity.length() > 0:
		sprite.play("Walk_" + direction)
	elif Input.is_action_just_pressed("attack")  == true:
		sprite.play("Attack_" + direction)
		attack()

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

func attack():
	if attack_in_progress == false:
		attack_in_progress = true
		$attack_cooldown.start()
		for enemy in enemies_in_attack_range:
			if enemy.alive:
				enemy.take_dmg(do_dmg())

func do_dmg():
	var min_dmg = damage * 0.9
	var max_dmg = damage * 1.1
	return randi_range(min_dmg, max_dmg)

func take_dmg(amount: int):
	print(str(self.get_type()) + " took " + str(amount) + " dmg.")
	health -= amount
	if health <= 0:
		print(str(self.get_type()) + " died.")
		alive = false
		$CollisionShape2D.queue_free()
		$attack_area.queue_free()
		sprite.play("Death")
		$death.start()

func _on_death_timeout() -> void:
	sprite.modulate.a -= 0.05
	#print(sprite.modulate.a)
	if sprite.modulate.a <= 0:
		self.queue_free()
	$death.start()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		enemies_in_attack_range.append(body)
		print(str(body.get_type()) + " entered " + type + "'s attack area.")

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body in enemies_in_attack_range:
		enemies_in_attack_range.erase(body)
		print(str(body.get_type()) + " exited " + type + "'s attack area.")

func _on_attack_cooldown_timeout() -> void:
	attack_in_progress = false

func update_gold(amount: int):
	gold += amount
	gold_display.text = "Gold: " + str(gold)
	
