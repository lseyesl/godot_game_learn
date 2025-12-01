# 总结

## 几种把场景添加到UI界面的方式

|方法|位置|适用场景|
|---|---|---|
|add_control_to_dock()|编辑器侧边栏|持久性工具面板|
|add_control_to_bottom_panel()|编辑器底部|输出、日志类面板|
|add_control_to_container()|特定编辑器区域|工具栏按钮、编辑器增强|
|add_tool_menu_item()|工具菜单|一次性操作|
|add_inspector_plugin()|属性检查器|自定义属性编辑器|
|Window/PopupPanel|独立窗口|复杂对话框、设置界面|

## 使用方法

1. add_control_to_dock

```gdscript
instance = preload("res://addons/my_plugin/panel.tscn").instantiate()
add_control_to_dock(DOCK_SLOT_RIGHT_UL, instance)
```

2. add_control_to_bottom_panel

```gdscript
instance = preload("res://addons/my_plugin/panel.tscn").instantiate()
add_control_to_bottom_panel(instance, 'my panel')
```

3. add_control_to_container

```gdscript
toolbar_button = Button.new()
toolbar_button.text = "My Tool"
toolbar_button.pressed.connect(_on_tool_pressed)
add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU, toolbar_button)
```

可用的容器类型：

- CONTAINER_TOOLBAR - 主工具栏
- CONTAINER_SPATIAL_EDITOR_MENU - 3D 编辑器菜单
- CONTAINER_SPATIAL_EDITOR_SIDE_LEFT - 3D 编辑器左侧
- CONTAINER_SPATIAL_EDITOR_SIDE_RIGHT - 3D 编辑器右侧
- CONTAINER_SPATIAL_EDITOR_BOTTOM - 3D 编辑器底部
- CONTAINER_CANVAS_EDITOR_MENU - 2D 编辑器菜单
- CONTAINER_CANVAS_EDITOR_SIDE_LEFT - 2D 编辑器左侧
- CONTAINER_CANVAS_EDITOR_SIDE_RIGHT - 2D 编辑器右侧
- CONTAINER_CANVAS_EDITOR_BOTTOM - 2D 编辑器底部
- CONTAINER_INSPECTOR_BOTTOM - 检查器底部
- CONTAINER_PROJECT_SETTING_TAB_LEFT - 项目设置左侧标签
- CONTAINER_PROJECT_SETTING_TAB_RIGHT - 项目设置右侧标签

4. add_tool_menu_item

```gdscript
add_tool_menu_item("My Tool", _on_tool_pressed)
```

5. add_tool_submenu_item

```gdscript
submenu = PopupMenu.new()
submenu.add_item("Action 1", 0)
submenu.add_item("Action 2", 1)
submenu.id_pressed.connect(_on_submenu_item)
add_tool_submenu_item("My Submenu", submenu)
```

6. add_inspector_plugin

```gdscript
instance = preload("res://addons/my_plugin/inspector_plugin.tscn").instantiate()
add_inspector_plugin(instance)
```

7. PopupPanel or Window

```gdscript
var popup_window: Window

func show_custom_window():
    popup_window = Window.new()
    popup_window.title = "My Custom Window"
    popup_window.size = Vector2i(400, 300)

    var content = preload("res://addons/my_plugin/content.tscn").instantiate()
    popup_window.add_child(content)

    EditorInterface.get_base_control().add_child(popup_window)
    popup_window.popup_centered()
```
