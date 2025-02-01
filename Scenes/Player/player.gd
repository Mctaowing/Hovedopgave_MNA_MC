class_name Player
extends CharacterBody2D

@onready var interaction_manager = InteractionManager
@onready var gold_display = $CanvasLayer/gold
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area_collision: CollisionShape2D = $attack_area/CollisionShape2D
@onready var health_bar: ProgressBar = $ProgressBar
@onready var camera: Camera2D = $Camera2D

var type: String = "Player"
var direction: String
var max_health: int
var health: int
var damage: int
var speed: int
var gold: int
var exp: int

var alive = true
var attack_in_progress = false
var enemies_in_attack_range = []
var in_combat = false

func get_type():
	return type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	direction = "forward"
	max_health = 200
	health = max_health
	health_bar.max_value = max_health
	damage = 20
	speed = 200
	gold = global.gold
	exp = global.exp
	gold_display.text = str(gold)
	set_camera_limit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if alive:
		get_input()
		move_and_slide()
		update_direction()
		update_animation()
		update_health_bar()
		teleport_out_of_dungeon()
		set_camera_limit()

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func update_direction():
	if Input.is_action_pressed("left"):
		direction = "sideway"
		sprite.flip_h = true
	elif Input.is_action_pressed("right"):
		direction = "sideway"
		sprite.flip_h = false
	elif Input.is_action_pressed("up"): 
		direction = "backward"
	elif Input.is_action_pressed("down"):
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
	in_combat = true
	$in_combat.start()
	var min_dmg = damage * 0.9
	var max_dmg = damage * 1.1
	return randi_range(min_dmg, max_dmg)

func take_dmg(amount: int):
	in_combat = true
	$in_combat.start()
	print(str(self.get_type()) + " took " + str(amount) + " dmg.")
	health -= amount
	if health <= 0:
		death()

func death():
	print(str(self.get_type()) + " died.")
	alive = false
	$CollisionShape2D.queue_free()
	$attack_area.queue_free()
	health_bar.queue_free()
	sprite.play("Death")
	$death.start()

func _on_death_timeout() -> void:
	sprite.modulate.a -= 0.05
	if sprite.modulate.a <= 0:
		GameOver.show_screen()
	$death.start()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		in_combat = true
		$in_combat.start()
		enemies_in_attack_range.append(body)
		print(str(body.get_type()) + " entered " + type + "'s attack area.")

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body in enemies_in_attack_range:
		enemies_in_attack_range.erase(body)
		print(str(body.get_type()) + " exited " + type + "'s attack area.")

func _on_attack_cooldown_timeout() -> void:
	attack_in_progress = false

func update_gold(amount: int):
	global.gold += amount
	gold = global.gold
	gold_display.text = str(gold)
	print(type + " got " + str(amount) + " gold")
	
func update_exp(amount: int):
	global.exp += amount
	exp = global.exp
	print(type + " got " + str(amount) + " exp")
	
func update_health_bar():
	health_bar.value = health
	if health > 0 && health < max_health:
		health_bar.visible = true
		if health_bar.value <= max_health * 0.25:
			health_bar.modulate = Color("#e50000", 1)
		elif health_bar.value <= max_health / 2:
			health_bar.modulate = Color("#e5b900", 1)
		else:
			health_bar.modulate = Color("#00d800", 1)
	else:
		health_bar.visible = false

func _on_regen_timer_timeout() -> void:
	if alive:
		if health < max_health && in_combat == false:
			health += 15
			print(type + " regained 15 HP")
			if health > max_health:
				health = max_health

func teleport_out_of_dungeon():
	if Input.is_action_just_pressed("teleport") and global.current_scene == "dungeon_generator":
		global.transition_scene = true
		get_tree().change_scene_to_file("res://Scenes/Game/game.tscn")
		global.finish_change_scenes()

func set_camera_limit():
	if global.current_scene == "game":
		camera.limit_left = 6
		camera.limit_top = 32
		camera.limit_bottom = 1184
		camera.limit_right = 1158
		camera.limit_smoothed = true
	else:
		camera.limit_left = -100000
		camera.limit_right = 100000
		camera.limit_top = -100000
		camera.limit_bottom = 100000

func _on_in_combat_timeout() -> void:
	in_combat = false
