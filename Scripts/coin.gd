extends Area2D

@onready var animat=$AnimatedSprite2D


func _process(delta):
	animat.play("coin")

func _on_area_entered(area):
	PlayerInvetory.add_coins(1)
	queue_free()
