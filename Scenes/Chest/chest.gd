class_name Chest
extends AnimatedSprite2D

@onready var animated_sprite_2d: AnimatedSprite2D = $"."
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var player = get_tree().get_first_node_in_group("player")

var is_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_open == false: 
		animated_sprite_2d.play("Closed")
	else: 
		animated_sprite_2d.play("Opened")
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	if is_open == false:
		animated_sprite_2d.play("OpenAnimation")
		is_open = true
		if player:
			player.update_gold(randi_range(1, 20))
