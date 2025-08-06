extends CharacterBody2D


const speed = 100.0
const jump_velocity = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var sides:int=1
@onready var animat=$AnimatedSprite2D

func _physics_process(delta):
	animat.play("walk")
	if not is_on_floor():
		velocity.y += gravity * delta
	move_walk()
	move_and_slide()

func move_walk():
	velocity.x = speed * sides


func _on_zone_damage_body_entered(body):
	if body.is_in_group("muralla"):
		animat.flip_h=!animat.flip_h
		sides*=-1


func _on_body_hitbox_area_entered(area):
	queue_free()
