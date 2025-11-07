extends Node3D

const ROT_SPEED = 0.003
const ZOOM_SPEED = 0.125
const MAIN_BUTTONS = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT | MOUSE_BUTTON_MASK_MIDDLE

var rot_x := -TAU / 16
var rot_y := TAU / 8
var camera_distance := 2.0
var base_height := int(ProjectSettings.get_setting('display/window/size/viewport_height'))

@onready var camera_holder: Node3D = $camera_holder
@onready var rotation_x : Node3D = $camera_holder/rotation_x
@onready var camera: Camera3D = $camera_holder/rotation_x/Camera3D

func _ready() -> void:
	# 初始化相机角度
	camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
	rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))
	


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_distance -= ZOOM_SPEED
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_distance += ZOOM_SPEED
		camera_distance = clamp(camera_distance, 1.5, 6)
	
	if event is InputEventMouseMotion and event.button_mask & MAIN_BUTTONS:
		var relative_motion: Vector2 = event.relative * DisplayServer.window_get_size().y / base_height
		rot_y -= relative_motion.x * ROT_SPEED
		rot_x -= relative_motion.y * ROT_SPEED
		rot_x = clamp(rot_x, -1.57, 0)
		camera_holder.transform.basis = Basis.from_euler(Vector3(0, rot_y, 0))
		rotation_x.transform.basis = Basis.from_euler(Vector3(rot_x, 0, 0))
	
	
func _process(delta: float) -> void:
	camera_holder.position.z = lerpf(camera_holder.position.z, camera_distance, 10 * delta)
