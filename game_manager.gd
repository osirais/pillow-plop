extends Node
class_name GameManager

signal score_changed(new_score: int)
signal bed_combined(level: int)
signal game_over

var score: int = 0
var beds_in_play: Array[BaseBed] = []
var max_beds: int = 30  


var level_scores = {
	1: 10,   
	2: 25,   
	3: 50,   
	4: 100,  
	5: 200,  
	6: 400,  
	7: 800,  
	8: 1600, 
	9: 3200, 
	10: 6400 
}

static var instance: GameManager

func _ready():
	instance = self

func add_bed(bed: BaseBed):
	beds_in_play.append(bed)
	bed.tree_exiting.connect(_on_bed_removed.bind(bed))
	
	
	if beds_in_play.size() > max_beds:
		emit_signal("game_over")

func _on_bed_removed(bed: BaseBed):
	beds_in_play.erase(bed)

func on_bed_combined(level: int):
	if level in level_scores:
		score += level_scores[level]
		emit_signal("score_changed", score)
		emit_signal("bed_combined", level)
		
		
		if level == 10:
			score += 5000
			emit_signal("score_changed", score)

func get_score() -> int:
	return score

func reset_game():
	score = 0
	beds_in_play.clear()
	emit_signal("score_changed", score)

func get_bed_count() -> int:
	return beds_in_play.size()
