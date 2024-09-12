extends Node2D

const BULLET = preload("res://Evade/bullet.tscn")

@onready var marker_1 = $Marker1
@onready var marker_2 = $Marker2

func _on_timer_timeout():
	var i := BULLET.instantiate()
	i.position = marker_1.position.lerp(marker_2.position, randf())
	add_child(i)
