@tool
extends Control

@onready var template_list: ItemList = $VBoxContainer/TemplateList
@onready var scene_name_input: LineEdit = $VBoxContainer/SceneName

signal request_close

const TEMPLATE_DIR = "res://addons/template/templates/"

func _ready() -> void:
	_refresh_template_list()

func _refresh_template_list() -> void:
	template_list.clear()
	var dir = DirAccess.open(TEMPLATE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() and file_name.ends_with(".tscn"):
				template_list.add_item(file_name)
			file_name = dir.get_next()
	else:
		print("Template directory not found: ", TEMPLATE_DIR)
		push_error("Template directory not found: ", TEMPLATE_DIR)
		# Optionally create it if it doesn't exist, or warn the user
		# DirAccess.make_dir_absolute(TEMPLATE_DIR) 

func _on_create_pressed() -> void:
	if template_list.get_selected_items().size() == 0:
		print("No template selected")
		push_error("No template selected")
		return
	
	var selected_idx = template_list.get_selected_items()[0]
	var template_file = template_list.get_item_text(selected_idx)
	var new_name = scene_name_input.text.strip_edges()
	
	if new_name == "":
		print("Please enter a scene name")
		push_warning("Please enter a scene name")
		return
	
	var source_path = TEMPLATE_DIR + template_file
	var target_path = "res://" + new_name + ".tscn"
	
	# Check if target already exists
	if FileAccess.file_exists(target_path):
		print("File already exists: ", target_path)
		push_error("File already exists: ", target_path)
		return
		
	var err = DirAccess.copy_absolute(source_path, target_path)
	if err == OK:
		print("Scene created successfully: ", target_path)
		push_warning("Scene created successfully: ", target_path)
		EditorInterface.open_scene_from_path(target_path)
		# Rescan filesystem to show new file
		EditorInterface.get_resource_filesystem().scan()
		_on_close_button_pressed()
	else:
		print("Failed to create scene. Error code: ", err)
		push_error("Failed to create scene. Error code: ", err)

func _on_close_button_pressed():
	emit_signal("request_close")
