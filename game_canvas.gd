extends CanvasLayer
class_name GameCanvas

@onready var score_label: Label
@onready var high_score_label: Label
@onready var bed_count_label: Label
@onready var level_indicator: Label
@onready var next_bed_preview: Control
@onready var combo_label: Label
@onready var progress_bar: ProgressBar
@onready var warning_label: Label

var preview_colors = {
	1: Color(0.8, 0.4, 0.4),   # Light Red
	2: Color(0.4, 0.8, 0.4),   # Light Green
	3: Color(0.4, 0.4, 0.8),   # Light Blue
	4: Color(0.8, 0.8, 0.4),   # Yellow
	5: Color(0.8, 0.4, 0.8),   # Purple
	6: Color(0.4, 0.8, 0.8),   # Cyan
	7: Color(1.0, 0.6, 0.2),   # Orange
	8: Color(1.0, 0.2, 0.6),   # Pink
	9: Color(0.6, 0.2, 1.0),   # Violet
	10: Color(1.0, 0.8, 0.0)   # Gold
}

var current_combo = 0
var max_combo = 0
var high_score = 0

func _ready():
	_setup_canvas_ui()
	_load_high_score()
	
	# Connect to game manager signals
	if GameManager.instance:
		GameManager.instance.score_changed.connect(_on_score_changed)
		GameManager.instance.bed_combined.connect(_on_bed_combined)

func _setup_canvas_ui():
	# Create main UI container
	var main_ui = Control.new()
	main_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(main_ui)
	
	# Top panel for score and stats
	var top_panel = _create_top_panel()
	main_ui.add_child(top_panel)
	
	# Side panel for next bed preview
	var side_panel = _create_side_panel()
	main_ui.add_child(side_panel)
	
	# Warning system
	var warning_panel = _create_warning_panel()
	main_ui.add_child(warning_panel)

func _create_top_panel() -> Panel:
	var panel = Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	panel.size.y = 120
	
	# Background styling
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0, 0, 0, 0.7)
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	panel.add_theme_stylebox_override("panel", style_box)
	
	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 40)
	panel.add_child(hbox)
	
	# Score section
	var score_section = VBoxContainer.new()
	hbox.add_child(score_section)
	
	score_label = Label.new()
	score_label.text = "Score: 0"
	score_label.add_theme_font_size_override("font_size", 28)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	score_section.add_child(score_label)
	
	high_score_label = Label.new()
	high_score_label.text = "High Score: " + str(high_score)
	high_score_label.add_theme_font_size_override("font_size", 18)
	high_score_label.add_theme_color_override("font_color", Color.YELLOW)
	score_section.add_child(high_score_label)
	
	# Stats section
	var stats_section = VBoxContainer.new()
	hbox.add_child(stats_section)
	
	bed_count_label = Label.new()
	bed_count_label.text = "Beds: 0"
	bed_count_label.add_theme_font_size_override("font_size", 20)
	bed_count_label.add_theme_color_override("font_color", Color.CYAN)
	stats_section.add_child(bed_count_label)
	
	combo_label = Label.new()
	combo_label.text = "Combo: 0"
	combo_label.add_theme_font_size_override("font_size", 18)
	combo_label.add_theme_color_override("font_color", Color.ORANGE)
	stats_section.add_child(combo_label)
	
	# Level indicator
	var level_section = VBoxContainer.new()
	hbox.add_child(level_section)
	
	level_indicator = Label.new()
	level_indicator.text = "Max Level: 1"
	level_indicator.add_theme_font_size_override("font_size", 20)
	level_indicator.add_theme_color_override("font_color", Color.GREEN)
	level_section.add_child(level_indicator)
	
	# Progress bar for game fill
	progress_bar = ProgressBar.new()
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	progress_bar.value = 0
	progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	level_section.add_child(progress_bar)
	
	return panel

func _create_side_panel() -> Panel:
	var panel = Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	panel.size = Vector2(200, 300)
	panel.position.y = 130
	
	# Background styling
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0, 0, 0, 0.6)
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_bottom_left = 10
	panel.add_theme_stylebox_override("panel", style_box)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 20)
	panel.add_child(vbox)
	
	# Next bed section
	var next_label = Label.new()
	next_label.text = "Next Bed:"
	next_label.add_theme_font_size_override("font_size", 18)
	next_label.add_theme_color_override("font_color", Color.WHITE)
	next_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(next_label)
	
	next_bed_preview = Control.new()
	next_bed_preview.custom_minimum_size = Vector2(100, 100)
	next_bed_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(next_bed_preview)
	
	# Instructions
	var instructions = Label.new()
	instructions.text = "Controls:\n• Click - Drop bed\n• WASD - Move\n• R - Restart"
	instructions.add_theme_font_size_override("font_size", 14)
	instructions.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(instructions)
	
	return panel

func _create_warning_panel() -> Control:
	var panel = Control.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.size = Vector2(400, 100)
	
	warning_label = Label.new()
	warning_label.text = ""
	warning_label.add_theme_font_size_override("font_size", 24)
	warning_label.add_theme_color_override("font_color", Color.RED)
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	warning_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(warning_label)
	
	return panel

func _on_score_changed(new_score: int):
	score_label.text = "Score: " + str(new_score)
	
	# Update high score
	if new_score > high_score:
		high_score = new_score
		high_score_label.text = "High Score: " + str(high_score)
		_save_high_score()
		
		# Flash effect for new high score
		var tween = create_tween()
		tween.tween_property(high_score_label, "modulate", Color.YELLOW, 0.2)
		tween.tween_property(high_score_label, "modulate", Color.WHITE, 0.2)

func _on_bed_combined(level: int):
	# Update bed count
	if GameManager.instance:
		bed_count_label.text = "Beds: " + str(GameManager.instance.get_bed_count())
		
		# Update progress bar based on bed count
		var fill_percentage = (GameManager.instance.get_bed_count() / float(GameManager.instance.max_beds)) * 100
		progress_bar.value = fill_percentage
		
		# Warning when getting close to full
		if fill_percentage > 80:
			_show_warning("DANGER! Too many beds!")
		elif fill_percentage > 60:
			_show_warning("Warning: Getting full!")
		else:
			_hide_warning()
	
	# Update combo
	current_combo += 1
	if current_combo > max_combo:
		max_combo = current_combo
	combo_label.text = "Combo: " + str(current_combo)
	
	# Create combo effect
	if JuiceSystem.instance and current_combo > 1:
		JuiceSystem.instance.create_combo_effect(current_combo)
	
	# Update level indicator
	var max_level = _get_max_level_reached()
	level_indicator.text = "Max Level: " + str(max_level)
	
	# Show combination effect
	_show_combination_effect(level)
	
	# Reset combo after delay
	var combo_timer = Timer.new()
	combo_timer.wait_time = 3.0
	combo_timer.one_shot = true
	combo_timer.timeout.connect(_reset_combo)
	add_child(combo_timer)
	combo_timer.start()

func _get_max_level_reached() -> int:
	var max_level = 1
	var beds = get_tree().get_nodes_in_group("beds")
	for bed in beds:
		if bed is BaseBed and bed.level > max_level:
			max_level = bed.level
	return max_level

func _reset_combo():
	current_combo = 0
	combo_label.text = "Combo: 0"

func _show_warning(text: String):
	warning_label.text = text
	warning_label.visible = true
	
	# Flash effect
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(warning_label, "modulate", Color.RED, 0.5)
	tween.tween_property(warning_label, "modulate", Color.WHITE, 0.5)

func _hide_warning():
	warning_label.visible = false

func _show_combination_effect(level: int):
	# Create a temporary label that shows the points gained
	var points_label = Label.new()
	var points = GameManager.instance.level_scores.get(level, 0)
	points_label.text = "+" + str(points)
	points_label.add_theme_font_size_override("font_size", 24)
	points_label.modulate = Color.YELLOW
	points_label.position = Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2)
	add_child(points_label)
	
	# Animate the label
	var tween = create_tween()
	tween.parallel().tween_property(points_label, "position", points_label.position + Vector2(0, -100), 1.5)
	tween.parallel().tween_property(points_label, "modulate", Color(1, 1, 0, 0), 1.5)
	tween.tween_callback(func(): points_label.queue_free())

func update_next_bed_preview(level: int):
	if not next_bed_preview:
		return
	
	# Clear previous preview
	for child in next_bed_preview.get_children():
		child.queue_free()
	
	# Create preview shape
	var preview_rect = ColorRect.new()
	preview_rect.color = preview_colors.get(level, Color.WHITE)
	preview_rect.size = Vector2(80, 80)
	preview_rect.position = Vector2(10, 10)
	next_bed_preview.add_child(preview_rect)
	
	# Add level text
	var level_text = Label.new()
	level_text.text = "Lv." + str(level)
	level_text.add_theme_font_size_override("font_size", 14)
	level_text.add_theme_color_override("font_color", Color.BLACK)
	level_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	level_text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	preview_rect.add_child(level_text)

func _restart_game():
	
	# Reset game state
	if GameManager.instance:
		GameManager.instance.reset_game()
	
	# Remove all beds
	var beds = get_tree().get_nodes_in_group("beds")
	for bed in beds:
		bed.queue_free()
	
	# Reset UI
	current_combo = 0
	combo_label.text = "Combo: 0"
	level_indicator.text = "Max Level: 1"
	progress_bar.value = 0
	_hide_warning()
	
	# Reset time scale
	Engine.time_scale = 1.0
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	# Update bed count regularly
	if GameManager.instance:
		bed_count_label.text = "Beds: " + str(GameManager.instance.get_bed_count())
		
		# Update progress bar
		var fill_percentage = (GameManager.instance.get_bed_count() / float(GameManager.instance.max_beds)) * 100
		progress_bar.value = fill_percentage

func _save_high_score():
	var save_file = FileAccess.open("user://high_score.save", FileAccess.WRITE)
	if save_file:
		save_file.store_32(high_score)
		save_file.close()

func _load_high_score():
	if FileAccess.file_exists("user://high_score.save"):
		var save_file = FileAccess.open("user://high_score.save", FileAccess.READ)
		if save_file:
			high_score = save_file.get_32()
			save_file.close()
