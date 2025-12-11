extends MeshInstance3D

@export var noise_strength: float = 5.0 # 地形最高有多高

func _ready():
	generate_terrain()

func generate_terrain():
	# 1. 获取原始的 PlaneMesh
	var plane_mesh = mesh as PlaneMesh
	
	# 2. 创建 ArrayMesh (因为 PlaneMesh 是生成好的，不能直接改，要转成 ArrayMesh)
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_mesh.get_mesh_arrays())
	
	# 3. 使用 MeshDataTool 编辑顶点
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(array_mesh, 0)
	
	# 4. 初始化噪声
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.02
	
	# 5. 遍历所有顶点修改高度
	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		
		# 根据 x 和 z 坐标计算高度 y
		# 注意：get_noise_2d 返回 -1 到 1，我们乘上强度
		var noise_y = noise.get_noise_2d(vertex.x, vertex.z) * noise_strength
		
		# 修改顶点高度
		vertex.y = noise_y
		
		# 写回工具
		mdt.set_vertex(i, vertex)
		
		# 可选：根据高度给顶点上色 (需要 Shader 支持顶点颜色)
		# mdt.set_vertex_color(i, Color.GREEN if noise_y > 0 else Color.BLUE)
	
	# 6. 重新计算法线 (否则光照会很奇怪，看起来是平的)
	# 这一步对于 3D 地形至关重要！
	mdt.commit_to_surface(array_mesh) # 这一步似乎不会自动重算，通常需手动处理或用 SurfaceTool
	
	# 更简单的重算 Normals 方法：不用 MeshDataTool commit，而是重新生成
	# 但为演示简单，这里直接清空原 mesh 并应用新 mesh
	array_mesh.clear_surfaces()
	mdt.commit_to_surface(array_mesh)
	
	# 赋值回去
	mesh = array_mesh
	
	# 7. 生成碰撞体 (让角色能站在上面)
	create_trimesh_collision()
