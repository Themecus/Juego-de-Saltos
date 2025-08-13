extends Area2D


func _on_area_entered(area):
	var next_scene = load("res://Scene/pruebas.tscn")  # Sin .tscn duplicado
	get_tree().change_scene_to_packed(next_scene)
