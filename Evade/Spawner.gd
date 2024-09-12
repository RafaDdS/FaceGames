extends Node2D

const BULLET = preload("res://Evade/bullet.tscn")

@onready var marker_1 = $Marker1
@onready var marker_2 = $Marker2

func _on_timer_timeout():
	var i := BULLET.instantiate()
	if randf() < 0.8:
		i.position = marker_1.position.lerp(marker_2.position, randf())
	else:
		i.position = Vector2(Player.instance.position.x, marker_1.position.y)
	add_child(i)
