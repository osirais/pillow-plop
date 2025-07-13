extends Control
class_name GameUI

@onready var score_label: Label
@onready var bed_count_label: Label
@onready var next_bed_preview: ColorRect

var preview_colors = {
	1: Color(0.8, 0.4, 0.4),   
	2: Color(0.4, 0.8, 0.4),   
	3: Color(0.4, 0.4, 0.8),   
	4: Color(0.8, 0.8, 0.4),   
	5: Color(0.8, 0.4, 0.8),   
	6: Color(0.4, 0.8, 0.8),   
	7: Color(1.0, 0.6, 0.2),   
	8: Color(1.0, 0.2, 0.6),   
	9: Color(0.6, 0.2, 1.0),   
	10: Color(1.0, 0.8, 0.0)   
}

func _ready():
	_setup_ui()
	
	
	if GameManager.instance:
		GameManager.instance.score_changed.connect(_on_score_changed)
		GameManager.instance.bed_combined.connect(_on_bed_combined)
		GameManager.instance.game_over.connect(_on_game_over)

func _setup_ui():
	
	var main_container = VBoxContainer.new()
	main_container.anchors_preset = Control.PRESET_TOP_LEFT
	main_container.position = Vector2(20, 20)
	add_child(main_container)
	
	
	score_label = Label.new()
	score_label.text = "Score: 0"
	score_label.add_theme_font_size_override("font_size", 24)
	main_container.add_child(score_label)
	
	
	bed_count_label = Label.new()
	bed_count_label.text = "Beds: 0"
	bed_count_label.add_theme_font_size_override("font_size", 18)
	main_container.add_child(bed_count_label)
	
	
	var instructions = Label.new()
	instructions.text = "Click to drop beds\nWASD to move\nSame level beds combine!"
	instructions.add_theme_font_size_override("font_size", 14)
	main_container.add_child(instructions)
	
	
	var preview_container = HBoxContainer.new()
	main_container.add_child(preview_container)
	
	var preview_label = Label.new()
	preview_label.text = "Next: "
	preview_label.add_theme_font_size_override("font_size", 16)
	preview_container.add_child(preview_label)
	
	next_bed_preview = ColorRect.new()
	next_bed_preview.size = Vector2(30, 30)
	next_bed_preview.color = preview_colors[1]
	preview_container.add_child(next_bed_preview)

func _on_score_changed(new_score: int):
	score_label.text = "Score: " + str(new_score)

func _on_bed_combined(level: int):
	
	if GameManager.instance:
		bed_count_label.text = "Beds: " + str(GameManager.instance.get_bed_count())
	
	
	_show_combination_effect(level)

func _on_game_over():
	
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	add_child(overlay)
	
	var container = VBoxContainer.new()
	container.anchors_preset = Control.PRESET_CENTER
	overlay.add_child(container)
	
	var game_over_label = Label.new()
	game_over_label.text = "GAME OVER!\nScore: " + str(GameManager.instance.get_score())
	game_over_label.add_theme_font_size_override("font_size", 36)
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(game_over_label)
	
	
	var restart_button = Button.new()
	restart_button.text = "Restart (R)"
	restart_button.add_theme_font_size_override("font_size", 20)
	restart_button.pressed.connect(_restart_game)
	container.add_child(restart_button)

func _restart_game():
	
	if GameManager.instance:
		GameManager.instance.reset_game()
	
	
	var beds = get_tree().get_nodes_in_group("beds")
	for bed in beds:
		bed.queue_free()
	
	
	Engine.time_scale = 1.0
	
	
	for child in get_children():
		if child is ColorRect and child.color == Color(0, 0, 0, 0.7):
			child.queue_free()

func _input(event):
	if event.is_action_pressed("ui_cancel"):  
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event.is_action_pressed("ui_accept"):  
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("restart"):  
		_restart_game()

func _show_combination_effect(level: int):
	
	var points_label = Label.new()
	var points = GameManager.instance.level_scores.get(level, 0)
	points_label.text = "+" + str(points)
	points_label.add_theme_font_size_override("font_size", 20)
	points_label.modulate = Color.YELLOW
	points_label.position = Vector2(200, 100)
	add_child(points_label)
	
	
	var tween = create_tween()
	tween.parallel().tween_property(points_label, "position", Vector2(200, 50), 1.0)
	tween.parallel().tween_property(points_label, "modulate", Color(1, 1, 0, 0), 1.0)
	tween.tween_callback(func(): points_label.queue_free())

func update_next_bed_preview(level: int):
	if next_bed_preview and level in preview_colors:
		next_bed_preview.color = preview_colors[level]

func _process(delta):
	
	if GameManager.instance:
		bed_count_label.text = "Beds: " + str(GameManager.instance.get_bed_count())
