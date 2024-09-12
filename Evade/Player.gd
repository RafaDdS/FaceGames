extends RigidBody2D

class_name Player

@onready var map = $".."
@onready var sprite = $Sprite2D
@onready var heart_1 = $Heart1
@onready var heart_2 = $Heart2

@export var max_vel := 350
@export var aceleration := 3000
@export var dead_zone := 35

var life := 3
var face_center:Vector2 = Vector2.ZERO

static var instance : Player

signal die

func _ready():
	instance = self
	sprite.texture = FaceDraw.img
	
	await get_tree().process_frame
	
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
	life -= 1
	
	if life == 2:
		heart_1.visible = false
		
	if life == 1:
		heart_2.visible = false
		
	if life <= 0:
		emit_signal("die")

func reset_face_position():
	face_center = Vector2.ZERO
