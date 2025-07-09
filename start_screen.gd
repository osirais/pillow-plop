extends Control

@onready var start_button = $VBoxContainer/StartButton

func _ready():
	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed():
	var game_scene = preload("res://World.tscn")
	get_tree().change_scene_to_packed(game_scene)
