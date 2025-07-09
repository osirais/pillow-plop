@tool
extends RigidBody3D

@export var body_color: Color = Color(1, 1, 1):
	set(value):
		body_color = value
		_update_material()

@export var SPEED: float = 5.0
@export var MOUSE_SENSITIVITY: float = 0.002

@onready var camera := $Camera3D
@onready var mesh := $MeshInstance3D

var yaw := 0.0
var pitch := 0.0

func _ready():
	if not Engine.is_editor_hint():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		freeze = false
	_update_material()

func _unhandled_input(event):
	if event is InputEventMouseMotion and not Engine.is_editor_hint():
		yaw -= event.relative.x * MOUSE_SENSITIVITY
		pitch -= event.relative.y * MOUSE_SENSITIVITY
		pitch = clamp(pitch, -PI / 2, PI / 2)

		rotation.y = yaw
		camera.rotation.x = pitch

func _physics_process(delta):
	if Engine.is_editor_hint():
		return

	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_back"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x

	direction.y = 0
	direction = direction.normalized()

	linear_velocity.x = direction.x * SPEED
	linear_velocity.z = direction.z * SPEED

func _update_material():
	if not mesh:
		return

	if mesh.material_override:
		var new_mat = mesh.material_override.duplicate()
		new_mat.albedo_color = body_color
		mesh.material_override = new_mat
	else:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = body_color
		mesh.material_override = mat
