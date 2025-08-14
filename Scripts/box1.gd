extends StaticBody2D

var buffCargado = preload("res://Scene/armor.tscn")
var life = 2
var buffeo = null
@onready var animat = $AnimatedSprite2D

func _on_crush_zone_area_entered(area):
	life -= 1
	
	if life == 1:
		buffeo = buffCargado.instantiate()
		buffeo.global_position = global_position
		animat.play("box_crush")
	
	if life <= 0:
		# Usar call_deferred para operaciones sensibles
		call_deferred("destroy_box")

func destroy_box():
	if is_instance_valid(buffeo):
		get_tree().current_scene.add_child(buffeo)
	queue_free()
