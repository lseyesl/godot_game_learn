# 

## DirAccess vs EditorFileSystem

DirAccess 是底层文件系统访问（运行时可用，只看文件）。
EditorFileSystem 是编辑器资源系统访问（仅编辑器可用，看的是“资源”及其元数据）。
以下是详细对比：

1. DirAccess.get_files_at('res://')
这是 Godot 的通用文件系统 API。

运行环境：所有环境（编辑器内、导出的游戏/应用运行时）。
功能：类似于操作系统层面的 ls 或 dir 命令。它只返回指定目录下的文件名字符串列表。

特点：
- “笨”：它不知道什么是“资源”，它只知道文件。它会列出 .import 文件，或者你可能不想看到的原始素材文件（取决于导出设置）。
- 无元数据：它无法直接告诉你这个文件是 Texture 还是 Script，你必须自己解析扩展名或加载它。
- 即时性：直接读取磁盘（或 PCK 包）。

适用场景：
- 在游戏运行时加载关卡列表。
- 读取自定义的配置文件（JSON, CFG）。
- 简单的文件遍历。

```gdscript
# 示例：运行时获取文件
var dir = DirAccess.open("res://levels/")
if dir:
    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
        if !dir.current_is_dir():
            print("Found file: " + file_name)
        file_name = dir.get_next()
```

2. get_editor_interface().get_resource_filesystem()
这是 Godot 编辑器工具（Editor Tools/Plugins）专用的 API。

运行环境：仅编辑器（@tool 脚本或插件）。在导出的游戏中调用会报错或返回 null。
功能：获取编辑器维护的资源文件系统缓存 (EditorFileSystem)。

特点：
- “聪明”：它了解 Godot 的导入系统。它知道 image.png 实际上对应一个 StreamTexture2D 资源。
- 树状结构：它返回的是 EditorFileSystemDirectory 对象，这是一个树形结构，包含子目录和文件。
- 元数据丰富：可以直接查询文件的资源类型（get_file_type）、脚本类名、依赖关系等，而无需实际加载文件。
- 扫描与更新：它负责监听文件变化并重新导入资源。

适用场景：
- 编写编辑器插件（Plugin）。
- 制作自定义的文件停靠栏（Dock）或资源选择器。
- 在编辑器工具中筛选特定类型的资源（例如：只查找所有继承自 Weapon 的资源）。

```gdscript
# 示例：编辑器插件中获取所有材质资源
# 必须在 @tool 下运行
var fs = get_editor_interface().get_resource_filesystem()
var root_dir = fs.get_filesystem() # 获取根目录 EditorFileSystemDirectory

func scan_dir(dir: EditorFileSystemDirectory):
    for i in dir.get_file_count():
        var type = dir.get_file_type(i)
        if type == "StandardMaterial3D":
            print("Found material: " + dir.get_file_path(i))
    
    for i in dir.get_subdir_count():
        scan_dir(dir.get_subdir(i))
```

核心区别对比表
| 特性	| DirAccess	| EditorFileSystem	|
|---|---|---|
| 可用性	| 运行时 (Runtime) & 编辑器	| 仅编辑器 (Editor Only)	|
| 返回数据	| 简单的文件名字符串数组	| 包含丰富信息的对象树 (`EditorFileSystemDirectory`)	|
| 导入系统	| 不感知 (看到原始文件)	| 感知 (看到导入后的资源结果)	|
| 性能	| 读取磁盘 I/O	| 读取内存中的编辑器缓存 (通常更快)	|
| 获取类型	| 需自行判断扩展名	| 直接通过 `get_file_type()` 获取 (如 "Scene", "Script")	|
| 典型用途	| 游戏逻辑、存档读写	| 制作插件、自动化工具、资源管理	|

## Plugin 生命周期方法

核心区别

|方法|触发时机|主要用途|
|---|---|---|
|_enable_plugin()|仅当用户在 项目设置 -> 插件 列表中勾选“启用”时调用一次。编辑器重启不会再次调用。|用于修改项目配置。例如：添加 Autoload (单例)、注册自定义类型、添加自定义导出插件等。|
|_disable_plugin()|仅当用户在 项目设置 -> 插件 列表中取消勾选“启用”时调用一次。|用于清理项目配置。例如：移除 Autoload、注销自定义类型等。|
|_enter_tree()|插件节点进入场景树时调用（每次打开编辑器、或启用插件时都会调用）。|用于当前会话的初始化。例如：连接信号、添加 UI 到编辑器面板、初始化变量。|
|_exit_tree()|插件节点退出场景树时调用（每次关闭编辑器、或禁用插件时都会调用）。|用于当前会话的清理。例如：断开信号、从编辑器面板移除 UI、释放内存。|

## 注意事项

使用普通的文件修改新创建脚本，打开脚本时会因为缓冲区问题，导致更新失败 

```gdscript
var script = load(path) as GDScript
var code = script.get_source_code()
if not code.contains(header_text):
    print('apply header text')
    code = header_text + "\n" + code
    script.set_source_code(code)
```

使用 `get_source_code` 获取文本，使用`set_source_code` 设置文本`
