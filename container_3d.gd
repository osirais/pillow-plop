@tool
extends Node3D

@export var width: float = 10.0:
	set(value):
		width = value
		_create_container()

@export var height: float = 5.0:
	set(value):
		height = value
		_create_container()

@export var depth: float = 3.0:
	set(value):
		depth = value
		_create_container()

@export var wall_thickness: float = 0.2:
	set(value):
		wall_thickness = value
		_create_container()

# Export a material property to assign from the editor
@export var wall_material: Material

func _ready():
	_create_container()

func _create_container():
	if not is_inside_tree():
		return

	for child in get_children():
		remove_child(child)
		child.queue_free()

	_add_wall(Vector3(0, -height/2 + wall_thickness/2, 0), Vector3(width, wall_thickness, depth), "Floor")
	_add_wall(Vector3(-width/2 + wall_thickness/2, 0, 0), Vector3(wall_thickness, height, depth), "LeftWall")
	_add_wall(Vector3(width/2 - wall_thickness/2, 0, 0), Vector3(wall_thickness, height, depth), "RightWall")
	_add_wall(Vector3(0, 0, depth/2 - wall_thickness/2), Vector3(width, height, wall_thickness), "BackWall")
	_add_wall(Vector3(0, 0, -depth/2 + wall_thickness/2), Vector3(width, height, wall_thickness), "FrontWall")

func _add_wall(position: Vector3, size: Vector3, name: String):
	var wall = StaticBody3D.new()
	wall.name = name
	wall.position = position

	var shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = size
	shape.shape = box_shape
	wall.add_child(shape)

	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = size
	mesh.mesh = box

	# Assign the exported material if set
	if wall_material != null:
		mesh.material_override = wall_material

	wall.add_child(mesh)

	if Engine.is_editor_hint():
		wall.owner = self

	add_child(wall)
