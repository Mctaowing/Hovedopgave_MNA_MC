extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var health

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = 100


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	updateAnimation()

func updateAnimation():
	if velocity.length() == 0 && !animated_sprite_2d.is_playing():
		animated_sprite_2d.play("Idle_forward")
