extends Node

var gold = 0

var transition_scene = false
var current_scene = "game"

func finish_change_scenes():
	if transition_scene == true:
		transition_scene = false
		if current_scene == "game":
			current_scene = "dungeon_generator"
		else:
			current_scene = "game"
