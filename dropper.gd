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

@onready var base_bed_script = preload("res://base_bed.gd")
var character_body: CharacterBody3D
var game_ui: SimpleGameUI
var next_bed_level: int = 1


var spawn_weights = {
	1: 50,  
	2: 30,  
	3: 15,  
	4: 5    
}

func _ready():
	if not Engine.is_editor_hint():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		# Initialize game manager
		var game_manager = GameManager.new()
		game_manager.name = "GameManager"
		get_tree().current_scene.add_child(game_manager)
		
		# Create and add Simple UI
		game_ui = SimpleGameUI.new()
		game_ui.name = "SimpleGameUI"
		get_tree().current_scene.add_child(game_ui)
		
		# Set initial next bed level
		next_bed_level = _get_random_bed_level()
		if game_ui:
			game_ui.call_deferred("update_next_bed_preview", next_bed_level)
	
	_create_body()

func _update_dropper_position():
	if character_body:
		character_body.global_transform.origin = dropper_position

func _input(event):
	if event.is_action_pressed("click") and character_body:
		var spawn_position = character_body.global_transform.origin - Vector3(0, 3, 0)
		var instance = _create_bed(next_bed_level)
		instance.global_transform.origin = spawn_position
		get_tree().current_scene.add_child(instance)
		
		
		if SoundManager.instance:
			SoundManager.instance.play_drop_sound()
		
		
		# Record bed drop
		if GameStats.instance:
			GameStats.instance.record_bed_drop()
		
		# Create drop ripple effect
		if JuiceSystem.instance:
			JuiceSystem.instance.create_drop_ripple(spawn_position)
		
		next_bed_level = _get_random_bed_level()
		if game_ui:
			game_ui.update_next_bed_preview(next_bed_level)

func _get_random_bed_level() -> int:
	var total_weight = 0
	for weight in spawn_weights.values():
		total_weight += weight
	
	var random_value = randi() % total_weight
	var current_weight = 0
	
	for level in spawn_weights:
		current_weight += spawn_weights[level]
		if random_value < current_weight:
			return level
	
	return 1  

func _create_bed(level: int) -> BaseBed:
	var bed = BaseBed.new()
	bed.level = level
	bed.name = "Bed_Level_" + str(level)
	return bed

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

func _process(delta):
	character_body.position.y = -10.10
