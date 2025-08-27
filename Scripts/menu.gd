extends Control
@onready var animat=$AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	animat.play("default")

func _on_button_2_pressed():
	get_tree().quit()

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scene/level_1.tscn")

func _on_button_3_pressed():
	var absolute_path = ProjectSettings.globalize_path("res://controls.txt")
	OS.shell_open(absolute_path)
