extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area_collision: CollisionShape2D = $attack_area/CollisionShape2D

var alive = true
var direction: String
var health: int
var damage: int
var speed: int
var dropped_exp

var attack_in_progress = false
var enemies_in_range = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	move_and_slide()
	update_direction()
	update_animation()

func update_direction():
	if abs(velocity.x) > abs(velocity.y):
		direction = "sideway"
		sprite.flip_h = velocity.x < 0
	elif velocity.y < 0: 
		direction = "backward"
	elif velocity.y > 0:
		direction = "forward"
	update_attack_area()

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

# formenlig overrides i child
func update_animation():
	if alive:
		if velocity.length() == 0 && !sprite.is_playing():
			sprite.play("Idle_" + direction)
		elif velocity.length() > 0:
			sprite.play("Walk_" + direction)
		elif attack_in_progress:
			sprite.play("Attack_" + direction)
			attack()

func attack():
	if attack_in_progress == false:
		attack_in_progress = true
		$attack_cooldown.start()
		for enemy in enemies_in_range:
			if enemy.alive:					# bug
				enemy.take_dmg(do_dmg())

func do_dmg():
	var min_dmg = damage * 0.9
	var max_dmg = damage * 1.1
	return randi_range(min_dmg, max_dmg)

func take_dmg(amount: int):
	health -= amount
	if health <= 0:
		alive = false
		sprite.play("Death")
		$death.start()

func _on_death_timeout() -> void:
	sprite.modulate.a -= 0.05
	print(sprite.modulate.a)
	if sprite.modulate.a <= 0:
		self.queue_free()
	$death.start()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if self.is_in_group("enemy"):
		if body.is_in_group("player"):
			enemies_in_range.append(body)
	elif self.is_in_group("player"):
		if body.is_in_group("enemy"):
			enemies_in_range.append(body)

func _on_attack_area_body_exited(body: Node2D) -> void:
	enemies_in_range.erase(body)

func _on_attack_cooldown_timeout() -> void:
	attack_in_progress = false
