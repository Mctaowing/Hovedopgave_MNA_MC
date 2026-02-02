extends Node

var gold = 0
var durries = 0
var player_exp = 0
var player_level = 1
var exp_thresholds = [0, 1000, 2000, 4000, 8000, 16000]

var transition_scene = false
var current_scene = "game"

func finish_change_scenes():
	if transition_scene == true:
		transition_scene = false
		if current_scene == "game":
			current_scene = "dungeon_generator"
		else:
			current_scene = "game"
