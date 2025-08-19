extends Area2D

var playerload

func _process(delta):
	if PlayerInvetory.life:
		#print("Jugador encontrado por ruta absoluta")
		pass
	else:
		PlayerInvetory.life=true
		playerload=load("res://Scene/player.tscn")
		var player=playerload.instantiate()
		add_child(player)
		
