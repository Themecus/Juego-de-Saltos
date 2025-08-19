extends Node

var coins_collected: int = 0
var life=true
func add_coins(amount: int):
	coins_collected += amount
	print("Monedas totales: ", coins_collected)
	

