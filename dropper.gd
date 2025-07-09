@tool
extends Node3D

@export var body_color: Color = Color(1, 1, 1):
	set(value):
		body_color = value
		_update_body_color()

@export var size: Vector3 = Vector3.ONE:
	set(value):
		size = value
		_create_body()

@export var speed: float = 5.0

@export var dropper_position: Vector3 = Vector3.ZERO:
	set(value):
		dropper_position = value
		_update_dropper_position()

@onready var object_to_spawn = preload("res://bed_level_1.tscn")
var rigid_body: RigidBody3D

func _ready():
	if not Engine.is_editor_hint():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_create_body()

func _update_dropper_position():
	if rigid_body:
		rigid_body.global_transform.origin = dropper_position

func _input(event):
	if event.is_action_pressed("click") and rigid_body:
		var spawn_position = rigid_body.global_transform.origin - Vector3(0, size.y / 2 + 0.1, 0)
		var instance = object_to_spawn.instantiate()
		instance.global_transform.origin = spawn_position
		get_tree().current_scene.add_child(instance)

func _physics_process(delta):
	if Engine.is_editor_hint() or not rigid_body:
		return

	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction -= rigid_body.transform.basis.z
	if Input.is_action_pressed("move_back"):
		direction += rigid_body.transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= rigid_body.transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += rigid_body.transform.basis.x

	direction.y = 0
	direction = direction.normalized()

	rigid_body.linear_velocity.x = direction.x * speed
	rigid_body.linear_velocity.z = direction.z * speed
	rigid_body.linear_velocity.y = 0

func _create_body():
	for child in get_children():
		if child is RigidBody3D:
			remove_child(child)
			child.queue_free()

	rigid_body = RigidBody3D.new()
	rigid_body.name = "DropperRigidBody"
	rigid_body.gravity_scale = 0
	rigid_body.collision_layer = 1
	rigid_body.collision_mask = 1
	add_child(rigid_body)
	rigid_body.owner = self.get_owner()

	_update_dropper_position()

	var collision = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = size
	collision.shape = box_shape
	collision.disabled = false
	rigid_body.add_child(collision)
	collision.owner = self.get_owner()

	var mesh = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	rigid_body.add_child(mesh)
	mesh.owner = self.get_owner()

	var mat = StandardMaterial3D.new()
	mat.albedo_color = body_color
	mesh.material_override = mat

func _update_body_color():
	if not rigid_body:
		return

	for child in rigid_body.get_children():
		if child is MeshInstance3D:
			var mat = child.material_override
			if mat:
				mat = mat.duplicate()
			else:
				mat = StandardMaterial3D.new()
			mat.albedo_color = body_color
			child.material_override = mat
