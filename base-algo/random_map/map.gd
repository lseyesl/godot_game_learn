extends Node2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayer

# 线程实例
var generation_thread: Thread

# --- 配置参数 ---
@export var map_width: int = 100
@export var map_height: int = 100
@export var noise_seed: int = 0
@export var noise_frequency: float = 0.05 # 越小地形越平缓，越大越破碎

var pending_map_data = []
const CELLS_PER_FRAME = 2000 # 每一帧只画 2000 个格子

# 定义图块在 TileSet 中的坐标 (Atlas Coordinates)
# 格式: Vector2i(列, 行)
const TILE_WATER = Vector2i(2, 0)
const TILE_SAND = Vector2i(0, 0)
const TILE_GRASS = Vector2i(1, 2)

# 定义 Source ID (通常是 0)
# 可以在MapSet 面板看到ID
const SOURCE_ID = 0

func _ready():
	generation_thread = Thread.new()
	start_generation()

func _input(event):
	# 按下空格键重新生成
	if event.is_action_pressed("ui_accept"):
		# 防止线程还在运行时重复启动
		if generation_thread.is_started():
			print("线程正在忙，请稍后...")
			return
			
		noise_seed = randi()
		start_generation()

func start_generation():
	print("开始在分线程计算地图数据...")
	tile_map_layer.clear() # 清除旧地图 (这个操作很快，可以在主线程做)
	
	# 启动线程
	# Callable 绑定：将生成函数绑定到线程，并传入所需的参数（如果有）
	# 这里我们不需要传参，因为直接读成员变量，但为了规范，通常把参数封包传入
	generation_thread.start(_thread_function)

# --- 这是在【分线程】运行的代码 ---
# 注意：这里绝对不能碰节点（不能 set_cell，不能 add_child）
func _thread_function():
	var map_data = [] # 用来存储计算结果的数组
	
	var noise = FastNoiseLite.new()
	noise.seed = noise_seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = noise_frequency
	
	# 繁重的循环计算在这里完成
	for x in range(map_width):
		for y in range(map_height):
			var noise_val = noise.get_noise_2d(x, y)
			var tile_coords = Vector2i()
			
			if noise_val < -0.2:
				tile_coords = TILE_WATER
			elif noise_val < 0.1:
				tile_coords = TILE_SAND
			else:
				tile_coords = TILE_GRASS
			
			# 我们不直接设置 cell，而是把“指令”存起来
			# 存入格式：{ "pos": Vector2i, "atlas": Vector2i }
			map_data.append({
				"pos": Vector2i(x, y),
				"atlas": tile_coords
			})
	
	# 计算完成，请求回到主线程应用数据
	# call_deferred 会在下一帧的主线程执行指定函数
	call_deferred("_on_generation_finished", map_data)

# --- 这是回到【主线程】运行的代码 ---
func _on_generation_finished(map_data):
	# 必须先等待线程安全结束
	generation_thread.wait_to_finish()
	
	print("计算完成，正在主线程绘制 %d 个图块..." % map_data.size())
	
	# # 这一步虽然在主线程，但因为只是简单的赋值，速度非常快
	# # 如果地图极大（如 1000x1000），这里可能会卡一下，后面有进阶优化法
	# for data in map_data:
	# 	tile_map_layer.set_cell(data["pos"], SOURCE_ID, data["atlas"])
		
	# print("地图绘制完毕！")
	
	# 将数据保存到成员变量，准备分批处理
	pending_map_data = map_data
	set_process(true) # 开启 _process

func _process(delta):
	if pending_map_data.is_empty():
		set_process(false)
		print("绘制完毕")
		return
	
	# 每一帧只处理一部分
	var batch_count = 0
	while not pending_map_data.is_empty() and batch_count < CELLS_PER_FRAME:
		var data = pending_map_data.pop_back()
		tile_map_layer.set_cell(data["pos"], SOURCE_ID, data["atlas"])
		batch_count += 1

# 重要：退出游戏时必须清理线程，否则会报错或内存泄漏
func _exit_tree():
	if generation_thread.is_started():
		generation_thread.wait_to_finish()
