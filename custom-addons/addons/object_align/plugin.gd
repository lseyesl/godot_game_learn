@tool
extends EditorPlugin

const MainPanel = preload("res://addons/object_align/ui.tscn")
var main_panel_instance

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	main_panel_instance = MainPanel.instantiate()
	# Add the main panel to the editor's dock.
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, main_panel_instance)
	# Connect to the selection changed signal.
	EditorInterface.get_selection().selection_changed.connect(_on_selection_changed)
	# Initial check.
	_on_selection_changed()


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	if main_panel_instance:
		remove_control_from_docks(main_panel_instance)
		main_panel_instance.free()


func _on_selection_changed() -> void:
	var selected = EditorInterface.get_selection().get_selected_nodes()
	if main_panel_instance:
		main_panel_instance.visible = not selected.is_empty()
