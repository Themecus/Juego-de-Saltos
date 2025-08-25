extends CharacterBody2D

const speed = 370.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var sides:int=1
var life=true
@onready var animat=$AnimatedSprite2D
@onready var collision_spikes=$zone_damage

func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y += gravity * delta
	if is_on_floor():
		move_walk()
	move_die()
	move_and_slide()

func move_walk():
	if life:
		animat.play("walk")
		velocity.x = speed * sides

func move_die():
	if life==false:
		velocity.x = 0
		animat.play("die")
		if animat.frame==6:
			queue_free()

func _on_zone_damage_body_entered(body):
	scale.x*=-1
	sides*=-1


func _on_body_hitbox_area_entered(area):
	life=false

