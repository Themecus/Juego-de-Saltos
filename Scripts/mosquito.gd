extends CharacterBody2D


const speed = 130.0
var detection=false
var action=false
var stun=false
var current_state:STATE=STATE.WALK
var rise=false
@onready var animat=$AnimatedSprite2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var assault_timer=$cooldown
@onready var reset_timer=$cooldown2
@onready var rise_timer=$cooldown3
@onready var detection_zone=$detection_zone
@onready var damage_zone=$zone_damage
enum STATE{
	WALK,
	DETECTION,
	ATTACK,
	STUN,
	RISE
}

func _physics_process(delta):
	match current_state:
		STATE.WALK:
			action = false
			move_walk(delta)
			if detection:
				assault_timer.start()
				current_state = STATE.DETECTION
				
		STATE.DETECTION:
			move_detection()
			if !detection:
				current_state = STATE.WALK
			elif action:
				current_state = STATE.ATTACK
				
		STATE.ATTACK:
			move_attack(delta)
			if stun:
				reset_timer.start()
				current_state = STATE.STUN
				
		STATE.STUN:
			move_stun()
			if !stun:
				rise_timer.start(0.2)
				current_state = STATE.RISE
				rise = false  # Asegurarse que rise empiece en false
				
		STATE.RISE:
			move_rise(delta)
			if rise:
				# Resetear todas las banderas relevantes
				rise = false
				stun = false
				action = false
				current_state = STATE.WALK

	move_and_slide()


func move_rise(delta):
	global_position.y = lerp(global_position.y, 0.0, 0.1 * delta * 30)#con esto podemos hacer movimiento indifenido suavizado

func move_stun():
	velocity = Vector2(0,0)
	detection_zone.monitoring=false
	detection_zone.monitorable=false
	damage_zone.monitoring=false
	damage_zone.monitorable=false

func move_attack(delta):
	velocity.x = 0
	if is_instance_valid(player) and player:
		global_position.y = lerp(global_position.y, 0.0, 0.1 * delta * -30)#con esto podemos hacer movimiento indifenido suavizado

func move_detection():
	if is_instance_valid(player) and player:
		global_position.x = lerp(global_position.x, player.global_position.x, 0.1)
		global_position.y = lerp(global_position.y, 150.0, 0.1)

	#los lerps funcionan para suavizar el movimiento lerp(valor_actual, valor_objetivo, factor_interpolacion)
	#el primer valor es con el que se esta igualando, el segundo el valor obejtivo como lo seria la velocidad
	#o una cosa, y el ultimo el parametro de interporlacion que se encarga de suavizar todo entre 0.1-1.0

func move_walk(delta):
	detection_zone.monitoring=true
	detection_zone.monitorable=true
	damage_zone.monitoring=true
	damage_zone.monitorable=true
	animat.play("walk")
	velocity.x = 100
	velocity.y=0

func _on_detection_zone_area_entered(area):
	if player:
		detection=true

func _on_detection_zone_area_exited(area):
	if player:
		detection=false

func _on_zone_hitbox_area_entered(area):
	queue_free()


func _on_cooldown_timeout():
	action=true

func _on_zone_damage_body_entered(body):
	if body.is_in_group("suelo"):
		stun=true


func _on_cooldown_2_timeout():
	stun=false


func _on_cooldown_3_timeout():
	rise=true
