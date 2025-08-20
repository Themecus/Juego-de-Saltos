extends Area2D

@onready var animat=$AnimatedSprite2D
@onready var flag=$"."
#@export var door_id: String = ""

#func _ready():
	# Generar ID único automáticamente si no se asignó uno
	#if door_id == "":
		#door_id = str(get_instance_id())  # ID único de instancia

func _process(delta):
	if animat.frame >= animat.sprite_frames.get_frame_count("rise") - 1:
		animat.play("static")
		flag.monitoring = false
		flag.monitorable = false


func _on_area_entered(area):
	if area.is_in_group("player"):
		PlayerInvetory.last_respawn_position = global_position
		animat.play("rise")
		#print("Jugador entró por la puerta: ", door_id)
		#PlayerInvetory.place=door_id
		
		
