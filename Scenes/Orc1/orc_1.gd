extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var orc: CharacterBody2D = $"."

var health = 100
var speed = 150
var player = null
var player_chase = false

@export var coordinates = position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	coordinates = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player_chase:
		position += (player.position - position)/speed
	
	updateAnimation()

func updateAnimation():
	if velocity.length() == 0 && !animated_sprite_2d.is_playing():
		animated_sprite_2d.play("Idle_forward")


func _on_area_2d_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true



func _on_area_2d_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false
