extends Node

var coins_collected: int = 0
var life=true
var last_respawn_position: Vector2 =Vector2(100, 100)
var level_position=1
var move_block=false
func add_coins(amount: int):
	coins_collected += amount
	print("Monedas totales: ", coins_collected)
	
	

