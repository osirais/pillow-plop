@tool
extends RigidBody3D

@export var bed_color: Color = Color(1, 1, 0)

@onready var mesh = $MeshInstance3D

func _ready():
	if mesh.mesh == null:
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(1, 0.2, 1)
		mesh.mesh = box_mesh
	if not has_node("CollisionShape3D"):
		var collision = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = Vector3(1, 0.2, 1)
		collision.shape = box_shape
		add_child(collision)
		collision.owner = self.get_owner()
	_update_color()

func _process(delta):
	if bed_color != mesh.material_override.albedo_color:
		_update_color()

func _update_color():
	var mat = StandardMaterial3D.new()
	mat.albedo_color = bed_color
	mesh.material_override = mat
