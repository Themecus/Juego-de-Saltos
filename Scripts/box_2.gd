extends StaticBody2D

var life=1
var parti=preload("res://Scene/particules1.tscn")
func _on_crush_zone_area_entered(area):
	life-=1
	if life==0:
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
