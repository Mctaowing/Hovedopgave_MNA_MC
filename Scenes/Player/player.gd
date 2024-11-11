extends CharacterBody2D

@export var speed = 200
var direction = ""

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_input()
	move_and_slide()
	updateDirection()
	updateAnimation()


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
