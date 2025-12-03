@tool
extends Node


var duration := 2.0
var tween: Tween

var toast_scene := preload("res://tsc/ToastManager.tscn")
var toast_instance: Control

func _ready():
	print('init toast scene')
	toast_instance = toast_scene.instantiate()
	EditorInterface.get_base_control().add_child(toast_instance)
	# toast_instance.show_toast('test toast')

func show_toast(msg: String):
	print('toast manage done')
	toast_instance.show_toast(msg)
