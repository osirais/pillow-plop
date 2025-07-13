extends Node
class_name EffectsManager

static var instance: EffectsManager
var camera: Camera3D
var original_camera_position: Vector3

func _ready():
	instance = self
	
	call_deferred("_find_camera")

func _find_camera():
	camera = get_viewport().get_camera_3d()
	if camera:
		original_camera_position = camera.position

func screen_shake(intensity: float, duration: float):
	if not camera:
		return
	
	var tween = create_tween()
	var shake_count = int(duration * 30)  
	
	for i in range(shake_count):
		var shake_offset = Vector3(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		
		tween.tween_property(
			camera, 
			"position", 
			original_camera_position + shake_offset, 
			duration / shake_count
		)
	
	
	tween.tween_property(camera, "position", original_camera_position, 0.1)

func create_explosion_effect(position: Vector3, color: Color):
	
	var explosion = Node3D.new()
	explosion.global_transform.origin = position
	get_tree().current_scene.add_child(explosion)
	
	
	for i in range(12):
		var particle = MeshInstance3D.new()
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius = 0.1
		sphere_mesh.height = 0.2
		particle.mesh = sphere_mesh
		
		var mat = StandardMaterial3D.new()
		mat.albedo_color = color
		mat.emission_enabled = true
		mat.emission = color * 0.8
		particle.material_override = mat
		
		explosion.add_child(particle)
		
		
		var angle = (i / 12.0) * TAU
		var direction = Vector3(cos(angle), 0, sin(angle))
		
		
		var tween = create_tween()
		tween.parallel().tween_property(particle, "position", direction * 3, 0.8)
		tween.parallel().tween_property(particle, "scale", Vector3.ZERO, 0.8)
		tween.parallel().tween_property(mat, "emission", Color.BLACK, 0.8)
	
	
	var cleanup_tween = create_tween()
	cleanup_tween.tween_interval(1.0)
	cleanup_tween.tween_callback(func(): explosion.queue_free())

func slow_time(duration: float, scale: float = 0.5):
	Engine.time_scale = scale
	
	var tween = create_tween()
	tween.tween_interval(duration)
	tween.tween_callback(func(): Engine.time_scale = 1.0)
