extends Node3D

const USE_CLAMP = false

@export var sensitivity = 0.005

@onready var camera_holder: Node3D = $camera_holder
@onready var camera: Camera3D = $camera_holder/Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


#
#func _unhandled_input(event: InputEvent) -> void:
	#'''
		#这种写法是有问题的，上下移动鼠标视角会已弧形的轨迹运动
	#'''
	#if event is InputEventMouseMotion:
		#var yaw_delta = -event.relative.x * sensitivity
		#var pitch_delta = -event.relative.y * sensitivity
		#var _basis = camera_holder.basis
		#
		#var yaw_quat = Quaternion(Vector3.UP, yaw_delta)
		#var pitch_quat = Quaternion(_basis.x,pitch_delta)
		#
			#
		#camera_holder.basis = camera_holder.basis * Basis(pitch_quat)
		#camera_holder.basis = Basis(yaw_quat) * camera_holder.basis
		#

#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#var yaw_delta = -event.relative.x * sensitivity
		#var pitch_delta = -event.relative.y * sensitivity
		#
		#camera_holder.rotate_object_local(Vector3.UP, yaw_delta)
		#camera_holder.rotate_x(pitch_delta)
		#
		##var rotation_rad = camera_holder.rotation
		##rotation_rad.x = clamp(rotation_rad.x, deg_to_rad(-90.0), deg_to_rad(89.0))
		##camera_holder.rotation = rotation_rad



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var yaw_delta = -event.relative.x * sensitivity
		var pitch_delta = -event.relative.y * sensitivity
		
		var local_x = camera_holder.basis.x
		var local_y = camera_holder.basis.y
		
		var yaw_quat = Quaternion(local_y, yaw_delta)
		var pitch_quat = Quaternion(local_x, pitch_delta)
		
		self.basis *= Basis(pitch_quat) * Basis(yaw_quat)
