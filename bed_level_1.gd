@tool
extends RigidBody3D

@export var bed_color: Color = Color(0, 1, 0)
@export var level: int = 1

@onready var mesh = $MeshInstance3D
@onready var bed_level2_scene = preload("res://bed_level_2.tscn")

var combined = false

func _ready():
	if mesh.mesh == null:
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(1, 0.2, 1)
		mesh.mesh = box_mesh

	contact_monitor = true
	max_contacts_reported = 10

	_update_color()

func _process(delta):
	if bed_color != mesh.material_override.albedo_color:
		_update_color()

func _update_color():
	var mat = StandardMaterial3D.new()
	mat.albedo_color = bed_color
	mesh.material_override = mat

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if combined:
		return

	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)
		if collider and collider is RigidBody3D and collider.get_script() == self.get_script():
			if level == 1 and collider.level == 1:
				combined = true
				collider.combined = true
				var new_bed = bed_level2_scene.instantiate()
				new_bed.global_transform.origin = (global_transform.origin + collider.global_transform.origin) * 0.5
				get_tree().current_scene.add_child(new_bed)
				queue_free()
				collider.queue_free()
				break
