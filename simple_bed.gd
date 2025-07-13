@tool
extends RigidBody3D
class_name SimpleBed

@export var bed_color: Color = Color.WHITE
@export var level: int = 1
@export var bed_size: Vector3 = Vector3(1, 0.2, 1)

@onready var mesh_instance: MeshInstance3D
@onready var collision_shape: CollisionShape3D

var combined = false
var can_combine = true

# Define bed properties for each level
var bed_properties = {
	1: { "color": Color(0.8, 0.4, 0.4), "size": Vector3(1.5, 1.5, 1.5), "shape": "sphere" },        
	2: { "color": Color(0.4, 0.8, 0.4), "size": Vector3(2.0, 2.0, 2.0), "shape": "sphere" },        
	3: { "color": Color(0.4, 0.4, 0.8), "size": Vector3(2.5, 2.5, 2.5), "shape": "cube" },          
	4: { "color": Color(0.8, 0.8, 0.4), "size": Vector3(3.0, 3.0, 3.0), "shape": "sphere" },        
	5: { "color": Color(0.8, 0.4, 0.8), "size": Vector3(3.5, 3.5, 3.5), "shape": "cube" },       
	6: { "color": Color(0.4, 0.8, 0.8), "size": Vector3(4.0, 4.0, 4.0), "shape": "sphere" },        
	7: { "color": Color(1.0, 0.6, 0.2), "size": Vector3(4.5, 4.5, 4.5), "shape": "cube" },          
	8: { "color": Color(1.0, 0.2, 0.6), "size": Vector3(5.0, 5.0, 5.0), "shape": "sphere" },        
	9: { "color": Color(0.6, 0.2, 1.0), "size": Vector3(5.5, 5.5, 5.5), "shape": "cube" },       
	10: { "color": Color(1.0, 0.8, 0.0), "size": Vector3(6.0, 6.0, 6.0), "shape": "sphere" }        
}

func _ready():
	if Engine.is_editor_hint():
		return
		
	# Add to beds group for bounds checking
	add_to_group("beds")
		
	# Set up bed properties based on level
	if level in bed_properties:
		bed_color = bed_properties[level]["color"]
		bed_size = bed_properties[level]["size"]
	
	_setup_mesh()
	_setup_collision()
	_setup_physics()
	_update_color()
	
	# Register with game manager
	call_deferred("_register_with_game_manager")

func _setup_mesh():
	# Create or get mesh instance
	if not has_node("MeshInstance3D"):
		mesh_instance = MeshInstance3D.new()
		mesh_instance.name = "MeshInstance3D"
		add_child(mesh_instance)
		mesh_instance.owner = self.get_owner()
	else:
		mesh_instance = $MeshInstance3D
	
	# Create mesh based on shape type
	var shape_type = "sphere"  # Default
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
		_:
			# Default to sphere
			var sphere_mesh = SphereMesh.new()
			sphere_mesh.radius = bed_size.x * 0.5
			sphere_mesh.height = bed_size.y
			mesh_instance.mesh = sphere_mesh

func _setup_collision():
	# Create or get collision shape
	if not has_node("CollisionShape3D"):
		collision_shape = CollisionShape3D.new()
		collision_shape.name = "CollisionShape3D"
		add_child(collision_shape)
		collision_shape.owner = self.get_owner()
	else:
		collision_shape = $CollisionShape3D
	
	# Create collision shape based on shape type
	var shape_type = "sphere"  # Default
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
		_:
			# Default to sphere
			var sphere_shape = SphereShape3D.new()
			sphere_shape.radius = bed_size.x * 0.5
			collision_shape.shape = sphere_shape

func _setup_physics():
	contact_monitor = true
	max_contacts_reported = 10
	gravity_scale = 1.0
	
	# Add some bounce
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
		if collider and collider is SimpleBed and collider.level == level and not collider.combined:
			# Check if we can combine (same level and not already combined)
			if level < 10:  # Max level is 10
				_combine_with(collider)
				break

func _combine_with(other_bed: SimpleBed):
	combined = true
	other_bed.combined = true
	
	# Calculate new position (midpoint between the two beds)
	var new_position = (global_transform.origin + other_bed.global_transform.origin) * 0.5
	
	# Notify game manager about combination
	if GameManager.instance:
		GameManager.instance.on_bed_combined(level)
	
	# Create new bed of next level
	var new_bed = SimpleBed.new()
	new_bed.level = level + 1
	new_bed.global_transform.origin = new_position
	
	# Add to scene
	get_tree().current_scene.add_child(new_bed)
	
	# Remove old beds
	queue_free()
	other_bed.queue_free()

func _register_with_game_manager():
	if GameManager.instance:
		GameManager.instance.add_bed(self)

func set_level(new_level: int):
	level = new_level
	if level in bed_properties:
		bed_color = bed_properties[level]["color"]
		bed_size = bed_properties[level]["size"]
		if mesh_instance:
			_setup_mesh()
			_setup_collision()
			_update_color()
