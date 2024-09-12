extends RigidBody2D

func _on_body_entered(body):
	if "collision" in body:
		body.collision()
	
	queue_free()
