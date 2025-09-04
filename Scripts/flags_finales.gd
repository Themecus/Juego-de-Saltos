extends Area2D

@onready var animat=$AnimatedSprite2D
@onready var animat_trans=$AnimatedSprite2D2/AnimationPlayer
@onready var flag=$"."

var level

func _process(delta):
	if animat.frame >= animat.sprite_frames.get_frame_count("rise") - 1:
		animat.play("static")
		flag.monitoring = false
		flag.monitorable = false
		await close_game_with_delay(1.0)  # 2 segundos de retraso

func close_game_with_delay(delay_seconds: float):
	await get_tree().create_timer(delay_seconds).timeout
	level=PlayerInvetory.level_position
	
	match level:
		1:
			animat_trans.play("entrance")
			await get_tree().create_timer(1.6).timeout
			get_tree().change_scene_to_file("res://Scene/level_2.tscn")
			
			PlayerInvetory.level_position+=1
		2:
			pass


func _on_area_entered(area):
	if area.is_in_group("player"):
		PlayerInvetory.move_block=true
		animat.play("rise")
