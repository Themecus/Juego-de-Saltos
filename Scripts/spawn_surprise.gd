extends Area2D

var enemy_load
var position_in_y=-300

func _on_area_exited(area):
	if area.is_in_group("player"):
		call_deferred("spawn_enemy")

func spawn_enemy():
	enemy_load = load("res://Scene/bug_red.tscn")
	var enemy = enemy_load.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = global_position + Vector2(0, position_in_y)
