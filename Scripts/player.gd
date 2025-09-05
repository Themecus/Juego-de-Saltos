extends CharacterBody2D

const speed = 300.0
const run_speed = 600.0
const jump_velocity = -500.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_state:STATE=STATE.IDLE
var current_anim_state: ANIM_STATE = ANIM_STATE.IDLE
var double_jump=false
var die=false
var hit=false
var move_block
var buff_armor=false
var frames_invenciblity=false
var can_take_damage: bool = true
var invincibility_time: float = 2.0  # 2 segundos de invencibilidad
@onready var zone_damage=$zone_damage
@onready var animat=$AnimatedSprite2D
@onready var animat_flag=$AnimatedSprite2D2
@onready var timer=$cooldown_hit
@onready var blink_timer = $BlinkTimer  # Referencia al Timer creado en el editor
enum STATE{#con esta maquina de estados controlaremos sus acciones
	IDLE,
	WALK,
	JUMP,
	RUN,
	FALL,
	EXIT
}

# Estados de animación
enum ANIM_STATE {
	IDLE,
	WALK,
	RUN,
	JUMP,
	HIT,
	TRANS,
	DEATH
}

func _physics_process(delta):
	move_block=PlayerInvetory.move_block
	match current_state:
		STATE.IDLE:#aqui estara quieto
			if !move_block:
				move_idle()
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
			if Input.is_action_pressed("jump"):#si presionamos espacio se activara el estado correspondiente
				current_state=STATE.JUMP
			elif Input.is_action_pressed("left"):#si presionamos A se activara el estado correspondiente
				current_state=STATE.WALK
			elif Input.is_action_pressed("right"):#si presionamos D se activara el estado correspondiente
				current_state=STATE.WALK
			elif not is_on_floor():
				current_state=STATE.FALL
			elif Input.is_action_pressed("exit"):
				current_state=STATE.EXIT
		STATE.WALK:#aqui caminando
			if !move_block:
				move_walk()
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
			if not Input.is_action_pressed("left") and not Input.is_action_pressed("right") and is_on_floor():#Si no se sgui presionando A o D vuelve a estar quieto
				current_state=STATE.IDLE
			elif Input.is_action_pressed("jump"): #si esta caminando puede saltar
				current_state=STATE.JUMP
			elif Input.is_action_pressed("speed"):
				current_state=STATE.RUN
			elif not is_on_floor():
				current_state=STATE.FALL
			elif Input.is_action_pressed("exit"):
				current_state=STATE.EXIT
			#elif Input.is_action_pressed("attack"): #si esta caminando puede saltar
				#current_state=STATE.ATTACK
			#print("moverse")
		STATE.JUMP:#aqui saltando
			if !move_block:
				move_jump()
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
			if is_on_floor():#Si vuelve a tocar el suelo vuelve a estat quieto
				current_state=STATE.IDLE
			elif Input.is_action_pressed("left") or Input.is_action_pressed("right"): #Si esta en el aire puede moverse
				current_state=STATE.WALK
			elif Input.is_action_pressed("exit"):
				current_state=STATE.EXIT
		STATE.RUN:#aqui corremos
			if !move_block:
				move_run(delta)
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
			if !Input.is_action_pressed("speed"):
				current_state=STATE.WALK
			elif Input.is_action_pressed("jump"):
				current_state=STATE.JUMP
			elif not is_on_floor():
				current_state=STATE.FALL
			elif Input.is_action_pressed("exit"):
				current_state=STATE.EXIT
		STATE.FALL:#si caemos sin saltar activara la colision de ataque
			move_fall()
			if is_on_floor():#Si vuelve a tocar el suelo vuelve a estat quieto
				current_state=STATE.IDLE
			elif Input.is_action_pressed("left") or Input.is_action_pressed("right"): #Si esta en el aire puede moverse
				current_state=STATE.WALK
			elif not Input.is_action_pressed("left") or not Input.is_action_pressed("right"): #Si esta en el aire puede moverse
				current_state=STATE.WALK
			elif Input.is_action_pressed("exit"):
				current_state=STATE.EXIT
		STATE.EXIT:#cierra el juego
			get_tree().quit()
	
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
		ANIM_STATE.DEATH:
			animat.play("death")
			await get_tree().create_timer(0.7).timeout
			animat.pause()

func move_run(delta):
	if is_on_floor():
		update_animation(ANIM_STATE.RUN)
		if Input.is_action_pressed("right"):
			flip_collisions(false)
			animat.flip_h=false
		if Input.is_action_pressed("left"):
			flip_collisions(true)
			animat.flip_h=true
	var direction = Input.get_axis("left", "right")# con esto sabremos a que lado esta yendo
	if direction:#dependiendo de la direccion se movera de una u otra lado
		velocity.x = direction * run_speed
	else:#esto lo que hace es que cuando dejemos de movernos limpie velocity.x con un zero y no alla residuos
		velocity.x = move_toward(velocity.x, 0, run_speed)

var jump_just_pressed = false

func _input(event):
	if event.is_action_pressed("jump"):
		jump_just_pressed = true

func move_jump():
	if not is_on_floor():
		zone_damage.monitoring = true
		zone_damage.monitorable = true
		update_animation(ANIM_STATE.JUMP)
	else:
		zone_damage.monitoring = false
		zone_damage.monitorable = false
	
	# Usar la variable jump_just_pressed
	if jump_just_pressed and (is_on_floor() or double_jump):
		jump_just_pressed = false
		velocity.y = jump_velocity
		double_jump = false if is_on_floor() else double_jump
	
	# Resetear la variable después de usarla
	

func move_fall():
	if not is_on_floor():
		zone_damage.monitoring = true
		zone_damage.monitorable = true
		update_animation(ANIM_STATE.JUMP)
	else:
		zone_damage.monitoring = false
		zone_damage.monitorable = false
	if Input.is_action_pressed("exit"):
		get_tree().quit()

func move_walk():
	if is_on_floor():
		update_animation(ANIM_STATE.WALK)
		if Input.is_action_pressed("right"):
			#Usar abs() para obtener el valor absoluto y luego multiplicar por 1 o -1
			flip_collisions(false)
			animat.flip_h=false
		if Input.is_action_pressed("left"):
			flip_collisions(true)
			animat.flip_h=true
	var direction = Input.get_axis("left", "right")# con esto sabremos a que lado esta yendo
	if direction:#dependiendo de la direccion se movera de una u otra lado
		velocity.x = direction * speed
	else:#esto lo que hace es que cuando dejemos de movernos limpie velocity.x con un zero y no alla residuos
		velocity.x = move_toward(velocity.x, 0, speed)

 #Función para voltear todas las colisiones
func flip_collisions(flip_left: bool):#esto es para el tema de girar colisiones
	var scale_x = abs($body_solid.scale.x) * (-1 if flip_left else 1)
	
	# Aplicar a todas las colisiones
	$body_solid.scale.x = scale_x
	$body_hitbox.scale.x = scale_x

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
		
	if area.is_in_group("flag"):
		pass
		return
	
	if is_on_floor():
		double_jump = false
		return

# Nueva función para manejar el daño
func take_damage():
	
	
	if !die:
		PlayerInvetory.life=false
		update_animation(ANIM_STATE.DEATH)
		PlayerInvetory.move_block=true
		await get_tree().create_timer(1.5).timeout
		PlayerInvetory.move_block=false
		queue_free()
	if die:
		can_take_damage = false
		update_animation(ANIM_STATE.HIT)
		start_invincibility_effect()
		# Iniciar temporizador de invencibilidad
		timer.start(invincibility_time)
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


