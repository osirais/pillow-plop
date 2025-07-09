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
var character_body: CharacterBody3D

func _ready():
	if not Engine.is_editor_hint():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_create_body()

func _update_dropper_position():
	if character_body:
		character_body.global_transform.origin = dropper_position

func _input(event):
	if event.is_action_pressed("click") and character_body:
		var spawn_position = character_body.global_transform.origin - Vector3(0, 3, 0)
		var instance = object_to_spawn.instantiate()
		instance.global_transform.origin = spawn_position
		get_tree().current_scene.add_child(instance)

func _physics_process(delta):
	if Engine.is_editor_hint() or not character_body:
		return

	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction -= character_body.transform.basis.z
	if Input.is_action_pressed("move_back"):
		direction += character_body.transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= character_body.transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += character_body.transform.basis.x

	direction.y = 0
	direction = direction.normalized()

	var velocity = direction * speed

	character_body.velocity.x = velocity.x
	character_body.velocity.z = velocity.z
	character_body.velocity.y = 0

	character_body.move_and_slide()

func _create_body():
	for child in get_children():
		if child is CharacterBody3D:
			remove_child(child)
			child.queue_free()

	character_body = CharacterBody3D.new()
	character_body.name = "DropperCharacterBody"
	add_child(character_body)
	character_body.owner = self.get_owner()

	_update_dropper_position()

	var collision = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = size
	collision.shape = box_shape
	collision.disabled = false
	character_body.add_child(collision)
	collision.owner = self.get_owner()

	var mesh = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	character_body.add_child(mesh)
	mesh.owner = self.get_owner()

	var mat = StandardMaterial3D.new()
	mat.albedo_color = body_color
	mesh.material_override = mat

func _update_body_color():
	if not character_body:
		return

	for child in character_body.get_children():
		if child is MeshInstance3D:
			var mat = child.material_override
			if mat:
				mat = mat.duplicate()
			else:
				mat = StandardMaterial3D.new()
			mat.albedo_color = body_color
			child.material_override = mat
