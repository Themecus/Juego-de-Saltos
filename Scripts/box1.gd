extends StaticBody2D

var life=2
@onready var animat=$AnimatedSprite2D

func _on_crush_zone_area_entered(area):
	life-=1
	if life==1:
		animat.play("box_crush")
	if life==0:
		queue_free()
	
