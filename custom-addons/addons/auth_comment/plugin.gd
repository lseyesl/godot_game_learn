@tool
extends EditorPlugin

var known_files := {}
var fs


func _enable_plugin() -> void:
	# Add autoloads here.
	print('plugin enabled')


func _disable_plugin() -> void:
	# Remove autoloads here.
	print('plugin disabled')


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	fs = EditorInterface.get_resource_filesystem()
	fs.connect("filesystem_changed", Callable(self, "_on_files_changed"))
	_scan_initial_files()


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	if fs.is_connected("filesystem_changed", Callable(self, "_on_files_changed")):
		fs.disconnect("filesystem_changed", Callable(self, "_on_files_changed"))


func _on_files_changed() -> void:
	var root_dir = fs.get_filesystem()
	if not root_dir:
		return
		
	var current_files := {}
	_scan_directory_recursive(root_dir, current_files)
	
	# Check for new files
	for file_path in current_files:
		if not known_files.has(file_path):
			print("Found new file: ", file_path)
			call_deferred("_prepend_to_file_safe", file_path, "# Auth by Lseyes")
	
	# Update known_files to match current state (handles deletions)
	known_files = current_files


func _scan_initial_files() -> void:
	var root_dir = fs.get_filesystem()
	if not root_dir:
		return
		
	var current_files := {}
	_scan_directory_recursive(root_dir, current_files)
	known_files = current_files


func _scan_directory_recursive(dir: EditorFileSystemDirectory, result_dict: Dictionary) -> void:
	# 1. 遍历当前目录下的所有文件
	for i in dir.get_file_count():
		var file_path = dir.get_file_path(i)
		
		# 检查是否是 .gd 脚本
		if file_path.ends_with(".gd"):
			result_dict[file_path] = true
	
	# 2. 递归遍历所有子目录
	for i in dir.get_subdir_count():
		_scan_directory_recursive(dir.get_subdir(i), result_dict)


func _prepend_to_file_safe(path: String, header_text: String) -> void:
	await get_tree().process_frame
	print('call _prepend_to_file_safe', path, header_text)
	var script = load(path) as GDScript
	var code = script.get_source_code()
	if not code.contains(header_text):
		print('apply header text')
		code = header_text + "\n" + code
		script.set_source_code(code)

	print('save done')
