@tool
extends EditorPlugin


const UI_SCENE = preload("res://addons/template/ui.tscn")
var ui_instance
var popup_window: Window
var toolbar_button: Button

func show_custom_window():
	if !popup_window:
		popup_window = Window.new()
		popup_window.title = "My Custom Window"
		popup_window.size = Vector2i(400, 500)

		ui_instance = UI_SCENE.instantiate()
		popup_window.add_child(ui_instance)

		EditorInterface.get_base_control().add_child(popup_window)
		popup_window.close_requested.connect(Callable(self, "_on_popup_close"))
		ui_instance.request_close.connect(Callable(self, "_on_popup_close"))
	
	popup_window.popup_centered()
	
func _on_popup_close() -> void:
	popup_window.hide()

func _enter_tree() -> void:
	# add_tool_menu_item("tmpl", Callable(self, "show_custom_window"))
	toolbar_button = Button.new()
	toolbar_button.text = "tmpl"
	toolbar_button.pressed.connect(show_custom_window)
	add_control_to_container(CONTAINER_TOOLBAR, toolbar_button)

func _exit_tree() -> void:
	remove_control_from_container(CONTAINER_TOOLBAR, toolbar_button)
	# emove_tool_menu_item("tmpl")
	if ui_instance:
		ui_instance.queue_free()
	if popup_window:
		popup_window.queue_free()
