extends Control

class_name VideoCapture

@onready var video_feed = %VideoFeed
@onready var fail = $Fail
@onready var end_label = $Fail/MarginContainer2/EndLabel

static var instance:VideoCapture
static var cap:CVVideoCapture
static var mat:CVMat
static var result:Array
static var croped:CVMat

var detector:CVFaceDetectorYN
var recognizer:CVFaceRecognizerSF
var feature_list := []

var should_draw_face:= true
var recognize_face_theshold := 0.5
var save_as_new_face_theshold := 0.3

var start_time:float

signal reset_face

func _ready():
	get_tree().paused = false
	start_time = Time.get_unix_time_from_system()
	
	instance = self
	cap = CVVideoCapture.new()
	cap.open(0, CVConsts.VideoCaptureAPIs.CAP_ANY, null)
	mat = cap.read()
	mat = CVCore.flip(mat, 1)
	
	detector = CVFaceDetectorYN.create("./Models/face_detection_yunet_2023mar.onnx", "", Vector2(mat.cols,mat.rows), {})
	recognizer = CVFaceRecognizerSF.create("./Models/face_recognition_sface_2021dec.onnx", "", {})
	
	await get_tree().process_frame
	
	Player.instance.connect("die", enable_fail_screen)
	
func _process(_delta):
	if !cap.is_opened():
		return
		
	mat = cap.read()
	mat = CVCore.flip(mat, 1)
	if mat.cols <= 0:
		return
		
	result = detector.detect_simplified(mat)
	
	recognize_face()
	
	video_feed.texture = mat.get_texture()

func recognize_face():
	for i in result:
		croped = recognizer.align_crop(mat, i["face_mat"])
		var feature = recognizer.feature(croped)
		
		var max_resem := -1.0
		for f in feature_list:
			if f["current"]: continue
			var resemblance := recognizer.match(feature, f["feature"], {})
			max_resem = max(max_resem, resemblance)
			if resemblance > recognize_face_theshold:
				f["current"] = i
			
	for f in feature_list:
		f["object"].visible = f["current"] != null
		if f["object"].visible: f["object"].position = f["current"]["right_eye"] + Vector2(50, 0)
		f["current"] = null

func _on_open_pressed():
	cap.open(0, CVConsts.VideoCaptureAPIs.CAP_ANY, null)

func _on_release_pressed():
	cap.release()

func _on_reset_pressed():
	emit_signal("reset_face")

func _on_restart_pressed():
	get_tree().reload_current_scene()

func _on_video_feed_pressed():
	video_feed.visible = !video_feed.visible

func enable_fail_screen():
	get_tree().paused = true
	
	var time : int = int(Time.get_unix_time_from_system() - start_time)
	if time<60:
		end_label.text = end_label.text.replace("XXX", str(time, " sec"))
	else:
		end_label.text = end_label.text.replace("XXX", str(time/60, " min ", time%60, " sec"))
	fail.visible = true
	
