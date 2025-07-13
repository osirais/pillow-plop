extends Node
class_name JuiceSystem

static var instance: JuiceSystem

func _ready():
	instance = self

func create_score_popup(position: Vector3, points: int, color: Color = Color.YELLOW):
	# Convert 3D position to 2D screen position
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var screen_pos = camera.unproject_position(position)
	
	# Create floating score label
	var score_label = Label.new()
	score_label.text = "+" + str(points)
	score_label.add_theme_font_size_override("font_size", 24)
	score_label.modulate = color
	score_label.position = screen_pos
	
	# Add to scene
	get_tree().current_scene.add_child(score_label)
	
	# Animate the label
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(score_label, "position", screen_pos + Vector2(0, -100), 1.0)
	tween.tween_property(score_label, "modulate", Color(color.r, color.g, color.b, 0), 1.0)
	tween.tween_property(score_label, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(score_label, "scale", Vector2(1, 1), 0.8)
	
	# Clean up
	tween.tween_callback(func(): score_label.queue_free())

func create_level_up_effect(position: Vector3, level: int):
	# Create "LEVEL UP!" text
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var screen_pos = camera.unproject_position(position)
	
	var level_label = Label.new()
	level_label.text = "LEVEL " + str(level) + "!"
	level_label.add_theme_font_size_override("font_size", 32)
	level_label.modulate = Color.GOLD
	level_label.position = screen_pos
	
	get_tree().current_scene.add_child(level_label)
	
	# Animate with bounce
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(level_label, "position", screen_pos + Vector2(0, -80), 1.5)
	tween.tween_property(level_label, "modulate", Color(1, 0.8, 0, 0), 1.5)
	tween.tween_property(level_label, "scale", Vector2(1.5, 1.5), 0.3)
	tween.tween_property(level_label, "scale", Vector2(1, 1), 0.9)
	
	tween.tween_callback(func(): level_label.queue_free())

func create_combo_effect(combo_count: int):
	if combo_count < 2:
		return
	
	var combo_label = Label.new()
	combo_label.text = str(combo_count) + "x COMBO!"
	combo_label.add_theme_font_size_override("font_size", 28)
	combo_label.modulate = Color.ORANGE
	combo_label.position = Vector2(get_viewport().size.x / 2 - 100, get_viewport().size.y / 2)
	
	get_tree().current_scene.add_child(combo_label)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(combo_label, "position", combo_label.position + Vector2(0, -50), 1.2)
	tween.tween_property(combo_label, "modulate", Color(1, 0.6, 0, 0), 1.2)
	tween.tween_property(combo_label, "scale", Vector2(1.3, 1.3), 0.2)
	tween.tween_property(combo_label, "scale", Vector2(1, 1), 1.0)
	
	tween.tween_callback(func(): combo_label.queue_free())

func create_max_level_celebration():
	# Create "MAX LEVEL!" celebration
	var celebration_label = Label.new()
	celebration_label.text = "🎉 MAX LEVEL REACHED! 🎉"
	celebration_label.add_theme_font_size_override("font_size", 40)
	celebration_label.modulate = Color.GOLD
	celebration_label.position = Vector2(get_viewport().size.x / 2 - 200, get_viewport().size.y / 2)
	
	get_tree().current_scene.add_child(celebration_label)
	
	# Rainbow effect
	var tween = create_tween()
	tween.set_loops()
	tween.tween_method(_rainbow_color.bind(celebration_label), 0.0, 1.0, 0.5)
	
	# Remove after 3 seconds
	var cleanup_tween = create_tween()
	cleanup_tween.tween_interval(3.0)
	cleanup_tween.tween_callback(func(): celebration_label.queue_free())

func _rainbow_color(label: Label, progress: float):
	var hue = progress * 360
	label.modulate = Color.from_hsv(hue / 360.0, 1.0, 1.0)

func create_drop_ripple(position: Vector3):
	# Create ripple effect when bed is dropped
	var ripple = Node3D.new()
	ripple.global_transform.origin = position
	get_tree().current_scene.add_child(ripple)
	
	# Create multiple rings
	for i in range(3):
		var ring = MeshInstance3D.new()
		var cylinder_mesh = CylinderMesh.new()
		cylinder_mesh.top_radius = 0.1
		cylinder_mesh.bottom_radius = 0.1
		cylinder_mesh.height = 0.1
		ring.mesh = cylinder_mesh
		
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(1, 1, 1, 0.3)
		mat.flags_transparent = true
		ring.material_override = mat
		
		ripple.add_child(ring)
		
		# Animate ring expansion
		var tween = create_tween()
		tween.tween_interval(i * 0.1)
		tween.parallel().tween_method(_scale_ring.bind(ring), 0.1, 3.0, 0.8)
		tween.parallel().tween_property(mat, "albedo_color", Color(1, 1, 1, 0), 0.8)
	
	# Clean up
	var cleanup_tween = create_tween()
	cleanup_tween.tween_interval(1.5)
	cleanup_tween.tween_callback(func(): ripple.queue_free())

func _scale_ring(ring: MeshInstance3D, scale_factor: float):
	var mesh = ring.mesh as CylinderMesh
	mesh.top_radius = scale_factor
	mesh.bottom_radius = scale_factor
