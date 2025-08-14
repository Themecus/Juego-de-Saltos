extends CharacterBody2D


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var grav=5
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta/grav
	move_and_slide()


func _on_take_zone_area_entered(area):
	queue_free()
