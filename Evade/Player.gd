extends RigidBody2D

@onready var sprite = $Sprite2D

@export var max_vel := 350
@export var aceleration := 3000
@export var dead_zone := 35

var face_center:Vector2 = Vector2.ZERO

func _ready():
	sprite.texture = FaceDraw.img
	VideoCapture.instance.connect("reset_face", reset_face_position)


func _process(_delta):
	if len(VideoCapture.result):
		var face = VideoCapture.result[0]
		var rect : CVRect = face["rect"]
		var center := rect.tl() + Vector2(rect.width, rect.height)/2
		var screen_size = Vector2(VideoCapture.mat.cols, VideoCapture.mat.rows)
		
		if face_center == Vector2.ZERO:
			face_center = center
		
		var vel = (center - face_center) / screen_size
		vel.x = clamp(vel.x * aceleration, -max_vel, max_vel)
		vel.y = 0
		
		if vel.length() > dead_zone:
			linear_velocity = vel
		else:
			linear_velocity = Vector2.ZERO

func collision():
	print("Ouch!")

func reset_face_position():
	face_center = Vector2.ZERO
