extends Area2D

@onready var animat=$AnimatedSprite2D
@onready var flag=$"."


func _process(delta):
	if animat.frame >= animat.sprite_frames.get_frame_count("rise") - 1:
		animat.play("static")
		flag.monitoring = false
		flag.monitorable = false


func _on_area_entered(area):
	if area.is_in_group("player"):
		animat.play("rise")
