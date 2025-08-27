extends Area2D

@onready var animat=$AnimatedSprite2D
@onready var flag=$"."


func _process(delta):
	if animat.frame >= animat.sprite_frames.get_frame_count("rise") - 1:
		animat.play("static")
		flag.monitoring = false
		flag.monitorable = false
		await close_game_with_delay(1.0)  # 2 segundos de retraso

func close_game_with_delay(delay_seconds: float):
	await get_tree().create_timer(delay_seconds).timeout
	get_tree().quit()


func _on_area_entered(area):
	if area.is_in_group("player"):
		animat.play("rise")
