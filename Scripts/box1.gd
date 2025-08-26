extends StaticBody2D

var buff_load
var life = 2
var parti=preload("res://Scene/particules1.tscn")
@onready var animat = $AnimatedSprite2D

func _on_crush_zone_area_entered(area):
	life -= 1
	
	if life == 1:
		animat.play("box_crush")
		gen_parti()
		gen_parti()
	
	if life <= 0:
		call_deferred("destroy_box")

func destroy_box():
	buff_load = load("res://Scene/armor.tscn")
	var buffe = buff_load.instantiate()
	get_tree().current_scene.add_child(buffe)
	buffe.global_position = global_position
	gen_parti()
	gen_parti()
	gen_parti()
	gen_parti()
	gen_parti()
	gen_parti()
	queue_free()

func gen_parti():
	var particul=parti.instantiate()
	particul.one_shot=true
	particul.position = position
	get_tree().current_scene.add_child(particul)
	await get_tree().create_timer(1).timeout
	destroy_part(particul)

func destroy_part(partii):
	partii.queue_free()
