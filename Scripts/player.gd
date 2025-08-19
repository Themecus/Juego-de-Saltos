extends CharacterBody2D

const speed = 300.0
const run_speed = 700.0
const jump_velocity = -500.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_state:STATE=STATE.IDLE
var current_anim_state: ANIM_STATE = ANIM_STATE.IDLE
var double_jump=false
var die=false
var hit=false
var buff_armor=false
var frames_invenciblity=false
var can_take_damage: bool = true
var invincibility_time: float = 2.0  # 2 segundos de invencibilidad
@onready var zone_damage=$zone_damage
@onready var animat=$AnimatedSprite2D
@onready var timer=$cooldown_hit
@onready var blink_timer = $BlinkTimer  # Referencia al Timer creado en el editor
enum STATE{#con esta maquina de estados controlaremos sus acciones
	IDLE,
	WALK,
	JUMP,
	RUN
}

# Estados de animación
enum ANIM_STATE {
	IDLE,
	WALK,
	RUN,
	JUMP,
	HIT,
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
		STATE.WALK:#aqui caminando
			move_walk()
			if not Input.is_action_pressed("left") and not Input.is_action_pressed("right") and is_on_floor():#Si no se sgui presionando A o D vuelve a estar quieto
				current_state=STATE.IDLE
			elif Input.is_action_pressed("jump"): #si esta caminando puede saltar
				current_state=STATE.JUMP
			elif Input.is_action_pressed("speed"):
				current_state=STATE.RUN
			#elif Input.is_action_pressed("attack"): #si esta caminando puede saltar
				#current_state=STATE.ATTACK
			#print("moverse")
		STATE.JUMP:#aqui saltando
			move_jump()
			if is_on_floor():#Si vuelve a tocar el suelo vuelve a estat quieto
				current_state=STATE.IDLE
			elif Input.is_action_pressed("left") or Input.is_action_pressed("right"): #Si esta en el aire puede moverse
				current_state=STATE.WALK
		STATE.RUN:#aqui corremos
			move_run(delta)
			if !Input.is_action_pressed("speed"):
				current_state=STATE.WALK
			elif Input.is_action_pressed("jump"):
				current_state=STATE.JUMP
	
	move_gravity(delta)
	move_and_slide()

# Función principal para actualizar animaciones
func update_animation(new_anim_state):
	#el hit es para forzar a que muestre la animacion de dano
		
	current_anim_state=new_anim_state
	match current_anim_state:
		ANIM_STATE.IDLE:
			if !hit and !buff_armor:
				animat.play("idle")
			if !hit and buff_armor:
				animat.play("idle_armor")
		ANIM_STATE.WALK:
			if !hit and !buff_armor:
				animat.play("walk")
			if !hit and buff_armor:
				animat.play("walk_armor")
		ANIM_STATE.RUN:
			if !hit and !buff_armor:
				animat.play("run")
		ANIM_STATE.JUMP:
			if !hit:
				animat.play("jump")
			if !hit and buff_armor:
				animat.play("jump_armor")
		ANIM_STATE.HIT:
			if hit:
				animat.play("hit")

func move_run(delta):
	if is_on_floor():
		update_animation(ANIM_STATE.WALK)
		if Input.is_action_pressed("right"):
			animat.flip_h=false
		if Input.is_action_pressed("left"):
			animat.flip_h=true
	var direction = Input.get_axis("left", "right")# con esto sabremos a que lado esta yendo
	if direction:#dependiendo de la direccion se movera de una u otra lado
		velocity.x = direction * run_speed
	else:#esto lo que hace es que cuando dejemos de movernos limpie velocity.x con un zero y no alla residuos
		velocity.x = move_toward(velocity.x, 0, run_speed)


func move_jump():
	if not is_on_floor():
		zone_damage.monitoring = true
		zone_damage.monitorable = true
		update_animation(ANIM_STATE.JUMP)
	else:
		zone_damage.monitoring = false
		zone_damage.monitorable = false
	if Input.is_action_pressed("jump") and is_on_floor() or double_jump==true:#para saltar
		velocity.y = jump_velocity
		double_jump=false

func move_walk():
	if is_on_floor():
		update_animation(ANIM_STATE.WALK)
		if Input.is_action_pressed("right"):
			animat.flip_h=false
		if Input.is_action_pressed("left"):
			animat.flip_h=true
	var direction = Input.get_axis("left", "right")# con esto sabremos a que lado esta yendo
	if direction:#dependiendo de la direccion se movera de una u otra lado
		velocity.x = direction * speed
	else:#esto lo que hace es que cuando dejemos de movernos limpie velocity.x con un zero y no alla residuos
		velocity.x = move_toward(velocity.x, 0, speed)

func move_gravity(delta):
	if not is_on_floor():#Esto actua como gravedad para personaje, sin este se queda tieso en el aire
		velocity.y += gravity * delta

func move_idle():
	update_animation(ANIM_STATE.IDLE)
	zone_damage.monitoring = false
	zone_damage.monitorable = false

func _on_body_hitbox_area_entered(area):
	#print("hola")
	if area.is_in_group("wall"):
		double_jump = true
		return  # Salimos de la función después de detectar pared
	
	if area.is_in_group("dmg") and can_take_damage:
		hit=true
		buff_armor=false
		take_damage()
		return
		
	if area.is_in_group("buff1"):
		die=true
		buff_armor=true
		return
	
	if is_on_floor():
		double_jump = false
		return

# Nueva función para manejar el daño
func take_damage():
	can_take_damage = false
	update_animation(ANIM_STATE.HIT)
	start_invincibility_effect()
	# Iniciar temporizador de invencibilidad
	timer.start(invincibility_time)
	
	if !die:
		PlayerInvetory.life=false
		queue_free()
	if die:
		die=false
	#agrega aqui la funcion para remover y agregar los poweups

func _on_cooldown_hit_timeout():
	can_take_damage = true
	hit=false
	#print("¡Ya puedes recibir daño nuevamente!")

# Función para efectos durante la invencibilidad
func start_invincibility_effect():
	# hacer parpadear el sprite
	var blink_timer = Timer.new()
	add_child(blink_timer)
	blink_timer.wait_time = 0.1
	blink_timer.timeout.connect(toggle_visibility)
	blink_timer.start()
	
	# Detener el parpadeo cuando termine la invencibilidad
	await get_tree().create_timer(invincibility_time).timeout
	blink_timer.stop()
	blink_timer.queue_free()
	animat.visible = true

func toggle_visibility():
	animat.visible = not animat.visible

func _on_zone_damage_area_entered(area):
	double_jump=true
	if is_on_floor():
		double_jump=false
	if velocity.y > 0:  # Jugador moviéndose hacia abajo
			velocity.y = -300  # Ajusta este valor para la altura del rebote


