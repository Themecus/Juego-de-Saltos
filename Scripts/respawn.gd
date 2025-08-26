extends Area2D

var playerload
var place
func _process(delta):
	if PlayerInvetory.life:
		#print("Jugador encontrado por ruta absoluta")
		pass
	else:
		place=PlayerInvetory.last_respawn_position
		PlayerInvetory.life=true
		
		place_respawn(place)
		
func place_respawn(place):
	playerload=load("res://Scene/player.tscn")
	var player=playerload.instantiate()
	get_tree().current_scene.add_child(player)
	player.global_position = place
	
	
   

