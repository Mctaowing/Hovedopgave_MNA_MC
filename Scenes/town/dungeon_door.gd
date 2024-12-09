extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_interact():
	global.transition_scene = true
	change_scene()

func change_scene():
	if global.transition_scene == true:
		if global.current_scene == "game":
			get_tree().change_scene_to_file("res://Scenes/DungeonGenerator/dungeon_generator.tscn")
			global.finish_change_scenes()
