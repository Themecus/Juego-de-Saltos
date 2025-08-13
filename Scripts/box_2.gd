extends StaticBody2D

var life=1

func _on_crush_zone_area_entered(area):
	life-=1
	if life==0:
		queue_free()
