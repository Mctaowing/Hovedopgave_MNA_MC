class_name Enemy
extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area_collision: CollisionShape2D = $attack_area/CollisionShape2D

var type: String
var direction: String = "forward"
var health: int
var damage: int
var speed: int
var dropped_exp
var spawn_coords: Vector2

var alive = true
var attack_in_progress = false
var enemies_in_attack_range = []
var player = null
var atk_anim = false

func get_type():
	return type
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if alive:
		move_and_slide()
		update_direction()
		update_animation()
		chase_player()
		attack()

func update_direction():
	if abs(velocity.x) > abs(velocity.y):
		direction = "sideway"
		sprite.flip_h = velocity.x < 0
	elif velocity.y < 0: 
		direction = "backward"
	elif velocity.y > 0:
		direction = "forward"
	update_attack_area()

# formenlig overrides i child
func update_animation():
	if velocity.length() == 0 && !sprite.is_playing() && attack_in_progress == false:
		sprite.play("Idle_" + direction)
	elif velocity.length() > 0:
		sprite.play("Walk_" + direction)
	elif atk_anim:
		sprite.play("Attack_" + direction)
		atk_anim = false

# SKAL overrides i child
# Transform2D(rotation: deg_to_rad() float, scale: Vector2, skew: float, position: Vector2)
func update_attack_area():
	if direction == "forward":
		pass
	elif direction == "backward":
		pass
	elif direction == "sideway":
		if sprite.flip_h: #left
			pass
		else: #right
			pass

func attack():
	if enemies_in_attack_range.size() > 0 && attack_in_progress == false:
		attack_in_progress = true
		$attack_cooldown.start()
		$attack_activation.start()

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
		$tracking_area.queue_free()
		sprite.play("Death")
		$death.start()

func _on_death_timeout() -> void:
	sprite.modulate.a -= 0.05
	#print(sprite.modulate.a)
	if sprite.modulate.a <= 0:
		self.queue_free()
	$death.start()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		enemies_in_attack_range.append(body)
		print(str(body.get_type()) + " entered " + type + "'s attack area.")

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body in enemies_in_attack_range:
		enemies_in_attack_range.erase(body)
		print(str(body.get_type()) + " exited " + type + "'s attack area.")

func _on_attack_cooldown_timeout() -> void:
	attack_in_progress = false

func _on_attack_activation_timeout() -> void:
	atk_anim = true
	for enemy in enemies_in_attack_range:
		if enemy.alive:
			enemy.take_dmg(do_dmg())

func chase_player():
	if self.is_in_group("enemy"):
		if attack_in_progress == false:
			if player != null:
				velocity = (player.position - position).normalized() * speed
			elif (position - spawn_coords).length() > 10:
				velocity = (spawn_coords - position).normalized() * speed
			else:
				velocity = Vector2(0, 0)
		else:
			velocity = Vector2(0, 0)

func _on_tracking_area_body_entered(body: Node2D) -> void:
	print("trigger entered")
	if self.is_in_group("enemy"):
		if body.is_in_group("player"):
			player = body
			print(type + " tracking " + body.get_type())

func _on_tracking_area_body_exited(body: Node2D) -> void:
	print("trigger exited")
	if self.is_in_group("enemy"):
		if body.is_in_group("player"):
			player = null
			print(type + " lost " + body.get_type())
