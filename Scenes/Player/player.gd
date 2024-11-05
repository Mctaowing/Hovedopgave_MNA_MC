extends CharacterBody2D



@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	attack()


func attack():
	if Input.is_action_just_pressed("attack") == true:
		animated_sprite_2d.play("Attack_forward")
	elif animated_sprite_2d.is_playing() == false:
		animated_sprite_2d.play("Idle_forward")
