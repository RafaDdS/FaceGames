extends Node2D

class_name FaceDraw

@export var viewport_size : Vector2 = Vector2(100, 100)

@onready var viewport = $".."

var result : Array
var img_cache : Texture
static var img : Texture

var right_eye_position  : Vector2
var left_eye_position  : Vector2
var nose_tip_position : Vector2
var right_mouth_position  : Vector2
var left_mouth_position : Vector2

func _ready():
	img = viewport.get_texture()
	viewport.size = viewport_size
	
func _process(_delta):
	if result != VideoCapture.result:
		result = VideoCapture.result
		if len(result) > 0:
			queue_redraw()
	
func _draw():
	for i in result:
		draw_face(i)

func draw_face(face):
	var rect : CVRect = face["rect"]
	var size := rect.br() - rect.tl() 
	var factor : float = size.y/viewport_size.y
	var ct := Vector2.LEFT * (size.x - size.y)/4
	#var mc := CVCore.mean(VideoCapture.croped, {}).get_vector3()/255.0
	
	var re = ct + (face["right_eye"] - rect.tl()) / factor
	var le = ct + (face["left_eye"] - rect.tl()) / factor
	var nt = ct + (face["nose_tip"] - rect.tl()) / factor
	var rm = ct + (face["right_mouth"] - rect.tl()) / factor
	var lm = ct + (face["left_mouth"] - rect.tl()) / factor
	
	right_eye_position = right_eye_position.lerp(re, 0.1)
	left_eye_position = left_eye_position.lerp(le, 0.1)
	nose_tip_position = nose_tip_position.lerp(nt, 0.1)
	right_mouth_position = right_mouth_position.lerp(rm, 0.1)
	left_mouth_position = left_mouth_position.lerp(lm, 0.1)
	
	var ec = (right_eye_position + left_eye_position)/ 2
	var nv = Vector2.RIGHT*10
	var ncpt = clamp(nt.x - ec.x + 10, 0, 20)/20
	
	draw_circle(viewport_size/2, viewport_size.x/2, Color.LIGHT_GOLDENROD)
	draw_circle(right_eye_position, 7, Color.SADDLE_BROWN)
	draw_circle(right_eye_position, 6, Color.LIGHT_GOLDENROD)
	draw_circle(right_eye_position, 3, Color.SADDLE_BROWN)
	draw_circle(left_eye_position, 7, Color.SADDLE_BROWN)
	draw_circle(left_eye_position, 6, Color.LIGHT_GOLDENROD)
	draw_circle(left_eye_position, 3, Color.SADDLE_BROWN)
	draw_polyline([Vector2.DOWN*10 + ec, nose_tip_position, nose_tip_position - nv * ncpt, nose_tip_position + nv * (1-ncpt)], Color.SADDLE_BROWN, 1)
	draw_line(right_mouth_position, left_mouth_position, Color.SADDLE_BROWN, 8)



