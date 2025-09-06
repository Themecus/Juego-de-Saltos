extends Node2D

@onready var animat_trans=$AnimatedSprite2D/AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerInvetory.move_block=true
	await get_tree().create_timer(0.5).timeout
	animat_trans.play("entrance")
	await get_tree().create_timer(0.4).timeout
	PlayerInvetory.move_block=false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
