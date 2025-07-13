extends Node
class_name GameStats

static var instance: GameStats

var total_beds_dropped = 0
var total_combinations = 0
var highest_combo = 0
var max_level_reached = 1
var total_score = 0
var session_time = 0.0
var levels_reached = {}  # Track how many of each level we've reached

func _ready():
	instance = self
	_load_stats()

func _process(delta):
	session_time += delta

func record_bed_drop():
	total_beds_dropped += 1

func record_combination(level: int, combo: int):
	total_combinations += 1
	if combo > highest_combo:
		highest_combo = combo
	
	if level > max_level_reached:
		max_level_reached = level
	
	# Track level occurrences
	if level in levels_reached:
		levels_reached[level] += 1
	else:
		levels_reached[level] = 1

func record_score(score: int):
	total_score = score

func get_stats_summary() -> Dictionary:
	return {
		"total_beds_dropped": total_beds_dropped,
		"total_combinations": total_combinations,
		"highest_combo": highest_combo,
		"max_level_reached": max_level_reached,
		"total_score": total_score,
		"session_time": session_time,
		"levels_reached": levels_reached
	}

func reset_session_stats():
	session_time = 0.0
	# Don't reset lifetime stats, only session ones

func _save_stats():
	var save_file = FileAccess.open("user://game_stats.save", FileAccess.WRITE)
	if save_file:
		var stats_data = {
			"total_beds_dropped": total_beds_dropped,
			"total_combinations": total_combinations,
			"highest_combo": highest_combo,
			"max_level_reached": max_level_reached,
			"total_score": total_score,
			"levels_reached": levels_reached
		}
		save_file.store_string(JSON.stringify(stats_data))
		save_file.close()

func _load_stats():
	if FileAccess.file_exists("user://game_stats.save"):
		var save_file = FileAccess.open("user://game_stats.save", FileAccess.READ)
		if save_file:
			var json_string = save_file.get_as_text()
			save_file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				var stats_data = json.data
				total_beds_dropped = stats_data.get("total_beds_dropped", 0)
				total_combinations = stats_data.get("total_combinations", 0)
				highest_combo = stats_data.get("highest_combo", 0)
				max_level_reached = stats_data.get("max_level_reached", 1)
				total_score = stats_data.get("total_score", 0)
				levels_reached = stats_data.get("levels_reached", {})

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_stats()
