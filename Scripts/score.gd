extends Label

@onready var score=$"."
var colletion=0
func _process(delta):
	score.text="X "+str(colletion)
	update_collettion()
	
func update_collettion():
	colletion=PlayerInvetory.coins_collected
