extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_screen():
	visible = true
	get_tree().paused = false

func restart_game():
	get_tree().paused = false
	hide_screen()
	if global.current_scene == "dungeon_generator":
		global.current_scene = "game"
		get_tree().change_scene_to_file("res://Scenes/Game/game.tscn")
	else:
		get_tree().reload_current_scene()

func hide_screen():
	visible = false
	get_tree().paused = false
