@tool
extends Control

@onready var x_align_btn = $VBoxContainer/Button

func _ready() -> void:
	print('x_align_btn', x_align_btn)
	x_align_btn.pressed.connect(_x_align_btn_click)
	
func _x_align_btn_click() -> void:
	var selected_nodes: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	
	if selected_nodes.size() < 2:
		print("Need at least 2 nodes selected to align.")
		return

	var target_x: float = 0.0
	
	# Determine target X from the first selected node
	# Note: The order of selected_nodes depends on selection order. 
	# Usually the last selected is the "active" one, but the user asked for "first node".
	# In Godot's array, index 0 is often the first one selected if using box select, 
	# or the first one clicked. Let's stick to index 0 as "first".
	# Ideally we should check if it's a Node2D or Node3D to access global_position.
	var first_node = selected_nodes[0]
	if "global_position" in first_node:
		target_x = first_node.global_position.x
	else:
		print("First node does not have global_position.")
		return
		
	var undo_redo = EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("Align X to First")
	
	for node in selected_nodes:
		if "global_position" in node:
			var new_pos = node.global_position
			new_pos.x = target_x
			
			undo_redo.add_do_property(node, "global_position", new_pos)
			undo_redo.add_undo_property(node, "global_position", node.global_position)
	
	undo_redo.commit_action()
