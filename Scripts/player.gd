extends CharacterBody2D

const speed = 300.0
const jump_velocity = -500.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_state:STATE=STATE.IDLE
@onready var animat=$AnimatedSprite2D
enum STATE{#con esta maquina de estados controlaremos sus acciones
	IDLE,
	WALK,
	JUMP,
	ATTACK
}

func _physics_process(delta):
	match current_state:
		STATE.IDLE:#aqui estara quieto
			move_idle()
			if Input.is_action_pressed("jump"):#si presionamos espacio se activara el estado correspondiente
				current_state=STATE.JUMP
			elif Input.is_action_pressed("left"):#si presionamos A se activara el estado correspondiente
				current_state=STATE.WALK
			elif Input.is_action_pressed("right"):#si presionamos D se activara el estado correspondiente
				current_state=STATE.WALK
			elif Input.is_action_pressed("attack"):#si presionamos D se activara el estado correspondiente
				current_state=STATE.ATTACK
			#print("quieto")
		STATE.WALK:#aqui caminando
			move_walk()
			if not Input.is_action_pressed("left") and not Input.is_action_pressed("right"):#Si no se sgui presionando A o D vuelve a estar quieto
				current_state=STATE.IDLE
			elif Input.is_action_pressed("jump"): #si esta caminando puede saltar
				current_state=STATE.JUMP
			elif Input.is_action_pressed("attack"): #si esta caminando puede saltar
				current_state=STATE.ATTACK
			#print("moverse")
		STATE.JUMP:#aqui saltando
			move_jump()
			if is_on_floor():#Si vuelve a tocar el suelo vuelve a estat quieto
				current_state=STATE.IDLE
			elif Input.is_action_pressed("left") or Input.is_action_pressed("right"): #Si esta en el aire puede moverse
				current_state=STATE.WALK
			elif Input.is_action_pressed("attack"): #Si esta en el aire puede moverse
				current_state=STATE.ATTACK
			#print("salto")
		STATE.ATTACK:#aqui atacamos
			move_attack()
			if Input.is_action_pressed("right") and not Input.is_action_pressed("attack"):
				current_state = STATE.WALK
			if Input.is_action_pressed("left") and not Input.is_action_pressed("attack"):
				current_state = STATE.WALK
			elif not Input.is_action_pressed("attack"): #Si esta en el aire puede moverse
				pass
	
	move_gravity(delta)
	move_and_slide()

func move_jump():
	if not is_on_floor():
		animat.play("jump")
	if Input.is_action_pressed("jump") and is_on_floor():#para saltar
		velocity.y = jump_velocity

func move_gravity(delta):
	if not is_on_floor():#Esto actua como gravedad para personaje, sin este se queda tieso en el aire
		velocity.y += gravity * delta

func move_idle():
	animat.play("idle")

func move_stop_animat():
	animat.pause()

func move_walk():
	if is_on_floor():
		animat.play("walk")
		if Input.is_action_pressed("right"):
			animat.flip_h=false
		if Input.is_action_pressed("left"):
			animat.flip_h=true
	var direction = Input.get_axis("left", "right")# con esto sabremos a que lado esta yendo
	if direction:#dependiendo de la direccion se movera de una u otra lado
		velocity.x = direction * speed
	else:#esto lo que hace es que cuando dejemos de movernos limpie velocity.x con un zero y no alla residuos
		velocity.x = move_toward(velocity.x, 0, speed)

func move_attack():
		animat.play("attack")
		if animat.frame == animat.sprite_frames.get_frame_count("attack")-1:
			if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
				current_state = STATE.WALK
			else:
				current_state = STATE.IDLE
		else:
			# Mantenerse en estado de ataque
			velocity.x = move_toward(velocity.x, 0, speed)

