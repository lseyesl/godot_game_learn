extends Node3D

@export var sensitivity = 0.2

@onready var camera_holder :Node3D = $camer_holder


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	'''
		因为只有两个自由度，所以从表现上来看是没有问题的
	'''
	if event is InputEventMouseMotion:
		camera_holder.rotation_degrees.y -= event.relative.x * sensitivity
		camera_holder.rotation_degrees.x -= event.relative.y * sensitivity
		
		camera_holder.rotation_degrees.x = clamp(camera_holder.rotation_degrees.x, -90.0, 90.0)
