extends StaticBody2D

var buff_load
var life = 2
@onready var animat = $AnimatedSprite2D

func _on_crush_zone_area_entered(area):
	life -= 1
	
	if life == 1:
		animat.play("box_crush")
	
	if life <= 0:
		call_deferred("destroy_box")

func destroy_box():
	buff_load = load("res://Scene/armor.tscn")
	var buffe = buff_load.instantiate()
	get_tree().current_scene.add_child(buffe)
	buffe.global_position = global_position
	
	queue_free()

