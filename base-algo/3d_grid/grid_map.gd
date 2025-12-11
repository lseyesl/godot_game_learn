extends GridMap

@export var map_size: int = 100
@export var noise_seed: int = 0
@export var noise_freq: float = 0.05

# 假设 MeshLibrary 里 ID 0 是地板，ID 1 是墙
const ID_FLOOR = 0
const ID_WALL = 1

func _ready():
	print("clear")
	clear() # 清空地图
	generate_grid_map()

	var used_cells = get_used_cells()
	print("当前 GridMap 中已生成的方块数量: ", used_cells.size())

func generate_grid_map():
	var noise = FastNoiseLite.new()
	noise.seed = noise_seed
	noise.frequency = noise_freq
	print('start')
	for x in range(map_size):
		for z in range(map_size):
			# 获取噪声高度 (0 到 1 之间)
			# abs() 确保是正数，作为堆叠的高度
			var height = abs(noise.get_noise_2d(x, z)) * 10
			
			# 转换为整数高度层级
			var y_levels = int(height)
			
			# 从底部堆叠到指定高度
			for y in range(y_levels):
				set_cell_item(Vector3i(x, y, z), ID_FLOOR)
			
			# 在顶部放个墙或者别的装饰（可选）
			if y_levels > 5:
				set_cell_item(Vector3i(x, y_levels, z), ID_WALL)
	
	print('end')
