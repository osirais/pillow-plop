extends Control
class_name SimpleGameUI

@onready var score_label: Label
@onready var bed_count_label: Label

func _ready():
	_setup_ui()
	
	# Connect to game manager signals
	if GameManager.instance:
		GameManager.instance.score_changed.connect(_on_score_changed)
		GameManager.instance.bed_combined.connect(_on_bed_combined)
		GameManager.instance.game_over.connect(_on_game_over)

func _setup_ui():
	# Create main container
	var main_container = VBoxContainer.new()
	main_container.anchors_preset = Control.PRESET_TOP_LEFT
	main_container.position = Vector2(20, 20)
	add_child(main_container)
	
	# Score label
	score_label = Label.new()
	score_label.text = "Score: 0"
	score_label.add_theme_font_size_override("font_size", 32)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	main_container.add_child(score_label)
	
	# Bed count label
	bed_count_label = Label.new()
	bed_count_label.text = "Beds: 0"
	bed_count_label.add_theme_font_size_override("font_size", 24)
	bed_count_label.add_theme_color_override("font_color", Color.CYAN)
	main_container.add_child(bed_count_label)
	
	# Instructions
	var instructions = Label.new()
	instructions.text = "Click to drop beds\nWASD to move\nSame level beds combine!"
	instructions.add_theme_font_size_override("font_size", 18)
	instructions.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	main_container.add_child(instructions)

func _on_score_changed(new_score: int):
	if score_label:
		score_label.text = "Score: " + str(new_score)

func _on_bed_combined(level: int):
	# Update bed count
	if GameManager.instance and bed_count_label:
		bed_count_label.text = "Beds: " + str(GameManager.instance.get_bed_count())

func _on_game_over():
	# Simple game over message
	if score_label:
		score_label.text = "GAME OVER! Final Score: " + str(GameManager.instance.get_score())
		score_label.add_theme_color_override("font_color", Color.RED)

func _process(delta):
	# Update bed count regularly
	if GameManager.instance and bed_count_label:
		bed_count_label.text = "Beds: " + str(GameManager.instance.get_bed_count())

func update_next_bed_preview(level: int):
	# Simple implementation for compatibility
	pass
