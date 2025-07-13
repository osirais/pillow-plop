@tool
extends RigidBody3D
class_name BaseBed

@export var bed_color: Color = Color.WHITE
@export var level: int = 1
@export var bed_size: Vector3 = Vector3(1, 0.2, 1)

@onready var mesh_instance: MeshInstance3D
@onready var collision_shape: CollisionShape3D

var combined = false
var can_combine = true


var bed_properties = {
	1: { "color": Color(0.8, 0.4, 0.4), "size": Vector3(1.5, 1.5, 1.5), "shape": "sphere" },        
	2: { "color": Color(0.4, 0.8, 0.4), "size": Vector3(2.0, 2.0, 2.0), "shape": "sphere" },        
	3: { "color": Color(0.4, 0.4, 0.8), "size": Vector3(2.5, 2.5, 2.5), "shape": "cube" },          
	4: { "color": Color(0.8, 0.8, 0.4), "size": Vector3(3.0, 3.0, 3.0), "shape": "sphere" },        
	5: { "color": Color(0.8, 0.4, 0.8), "size": Vector3(3.5, 3.5, 3.5), "shape": "pyramid" },       
	6: { "color": Color(0.4, 0.8, 0.8), "size": Vector3(4.0, 4.0, 4.0), "shape": "sphere" },        
	7: { "color": Color(1.0, 0.6, 0.2), "size": Vector3(4.5, 4.5, 4.5), "shape": "cube" },          
	8: { "color": Color(1.0, 0.2, 0.6), "size": Vector3(5.0, 5.0, 5.0), "shape": "sphere" },        
	9: { "color": Color(0.6, 0.2, 1.0), "size": Vector3(5.5, 5.5, 5.5), "shape": "pyramid" },       
	10: { "color": Color(1.0, 0.8, 0.0), "size": Vector3(6.0, 6.0, 6.0), "shape": "sphere" }        
}

func _ready():
	if Engine.is_editor_hint():
		return
		
	
	add_to_group("beds")
		
	
	if level in bed_properties:
		bed_color = bed_properties[level]["color"]
		bed_size = bed_properties[level]["size"]
	
	_setup_mesh()
	_setup_collision()
	_setup_physics()
	_update_color()
	
	
	call_deferred("_register_with_game_manager")

func _setup_mesh():
	
	if not has_node("MeshInstance3D"):
		mesh_instance = MeshInstance3D.new()
		mesh_instance.name = "MeshInstance3D"
		add_child(mesh_instance)
		mesh_instance.owner = self.get_owner()
	else:
		mesh_instance = $MeshInstance3D
	
	
	var shape_type = "sphere"  
	if level in bed_properties and "shape" in bed_properties[level]:
		shape_type = bed_properties[level]["shape"]
	
	match shape_type:
		"sphere":
			var sphere_mesh = SphereMesh.new()
			sphere_mesh.radius = bed_size.x * 0.5
			sphere_mesh.height = bed_size.y
			mesh_instance.mesh = sphere_mesh
		"cube":
			var box_mesh = BoxMesh.new()
			box_mesh.size = bed_size
			mesh_instance.mesh = box_mesh
		"pyramid":
			
			var pyramid_mesh = _create_pyramid_mesh(bed_size)
			mesh_instance.mesh = pyramid_mesh
		_:
			
			var sphere_mesh = SphereMesh.new()
			sphere_mesh.radius = bed_size.x * 0.5
			sphere_mesh.height = bed_size.y
			mesh_instance.mesh = sphere_mesh

func _setup_collision():
	
	if not has_node("CollisionShape3D"):
		collision_shape = CollisionShape3D.new()
		collision_shape.name = "CollisionShape3D"
		add_child(collision_shape)
		collision_shape.owner = self.get_owner()
	else:
		collision_shape = $CollisionShape3D
	
	
	var shape_type = "sphere"  
	if level in bed_properties and "shape" in bed_properties[level]:
		shape_type = bed_properties[level]["shape"]
	
	match shape_type:
		"sphere":
			var sphere_shape = SphereShape3D.new()
			sphere_shape.radius = bed_size.x * 0.5
			collision_shape.shape = sphere_shape
		"cube":
			var box_shape = BoxShape3D.new()
			box_shape.size = bed_size
			collision_shape.shape = box_shape
		"pyramid":
			
			var box_shape = BoxShape3D.new()
			box_shape.size = bed_size
			collision_shape.shape = box_shape
		_:
			
			var sphere_shape = SphereShape3D.new()
			sphere_shape.radius = bed_size.x * 0.5
			collision_shape.shape = sphere_shape

func _setup_physics():
	contact_monitor = true
	max_contacts_reported = 10
	gravity_scale = 1.0
	
	
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = 0.3
	physics_material_override.friction = 0.8

func _update_color():
	if not mesh_instance:
		return
		
	var mat = StandardMaterial3D.new()
	mat.albedo_color = bed_color
	mat.metallic = 0.2
	mat.roughness = 0.8
	mesh_instance.material_override = mat

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if combined or not can_combine:
		return

	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)
		if collider and collider is BaseBed and collider.level == level and not collider.combined:
			
			if level < 10:  
				_combine_with(collider)
				break

func _combine_with(other_bed: BaseBed):
	combined = true
	other_bed.combined = true
	
	
	if SoundManager.instance:
		SoundManager.instance.play_combine_sound(level)
	
	
	if EffectsManager.instance:
		var shake_intensity = 0.1 + (level * 0.05)
		EffectsManager.instance.screen_shake(shake_intensity, 0.2)
		
		
		if level >= 5:
			EffectsManager.instance.slow_time(0.5, 0.7)
		
		
		var combine_position = (global_transform.origin + other_bed.global_transform.origin) * 0.5
		EffectsManager.instance.create_explosion_effect(combine_position, bed_color)
	
	
	var new_position = (global_transform.origin + other_bed.global_transform.origin) * 0.5
	
	
	if GameManager.instance:
		GameManager.instance.on_bed_combined(level)
	
	
	var new_bed = BaseBed.new()
	new_bed.level = level + 1
	new_bed.global_transform.origin = new_position
	
	
	get_tree().current_scene.add_child(new_bed)
	
	
	_create_combination_effect(new_position)
	
	
	queue_free()
	other_bed.queue_free()

func _register_with_game_manager():
	if GameManager.instance:
		GameManager.instance.add_bed(self)

func _create_combination_effect(position: Vector3):
	
	var effect = Node3D.new()
	effect.global_transform.origin = position
	get_tree().current_scene.add_child(effect)
	
	
	for i in range(8):
		var particle = MeshInstance3D.new()
		var cube_mesh = BoxMesh.new()
		cube_mesh.size = Vector3(0.1, 0.1, 0.1)
		particle.mesh = cube_mesh
		
		var mat = StandardMaterial3D.new()
		mat.albedo_color = bed_color
		mat.emission_enabled = true
		mat.emission = bed_color * 0.5
		particle.material_override = mat
		
		effect.add_child(particle)
		
		
		var direction = Vector3(
			randf_range(-1, 1),
			randf_range(0, 1),
			randf_range(-1, 1)
		).normalized()
		
		particle.position = direction * 0.5
		
		
		var tween = create_tween()
		tween.parallel().tween_property(particle, "position", direction * 2, 0.5)
		tween.parallel().tween_property(particle, "scale", Vector3.ZERO, 0.5)
		tween.parallel().tween_property(mat, "albedo_color", Color(mat.albedo_color.r, mat.albedo_color.g, mat.albedo_color.b, 0), 0.5)
	
	
	var cleanup_tween = create_tween()
	cleanup_tween.tween_interval(0.6)
	cleanup_tween.tween_callback(func(): effect.queue_free())

func set_level(new_level: int):
	level = new_level
	if level in bed_properties:
		bed_color = bed_properties[level]["color"]
		bed_size = bed_properties[level]["size"]
		if mesh_instance:
			_setup_mesh()
			_setup_collision()
			_update_color()

func _create_pyramid_mesh(size: Vector3) -> ArrayMesh:
	var array_mesh = ArrayMesh.new()
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	var indices = PackedInt32Array()
	
	
	var half_x = size.x * 0.5
	var half_z = size.z * 0.5
	var height = size.y
	
	
	vertices.push_back(Vector3(-half_x, 0, -half_z))  
	vertices.push_back(Vector3(half_x, 0, -half_z))   
	vertices.push_back(Vector3(half_x, 0, half_z))    
	vertices.push_back(Vector3(-half_x, 0, half_z))   
	
	
	vertices.push_back(Vector3(0, height, 0))         
	
	
	indices.append_array([0, 2, 1, 0, 3, 2])
	
	
	indices.append_array([0, 1, 4])  
	indices.append_array([1, 2, 4])  
	indices.append_array([2, 3, 4])  
	indices.append_array([3, 0, 4])  
	
	
	for i in range(vertices.size()):
		normals.push_back(Vector3(0, 1, 0))
		uvs.push_back(Vector2(0, 0))
	
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return array_mesh
