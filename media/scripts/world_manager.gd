extends Node
class_name WorldManager

var generator : WorldGenerator
@export var sectors : Dictionary[Vector3i, Sector] = {}
const SECTOR_SIZE = Sector.SIZE

var pending_meshes : Array = [] # Очередь из мешей готовых к добавлению в дерево
const MESHES_PER_FRAME : int = 20 # Скорость установки мешей за кадр

# ГЛАВНЫЙ ПОТОК
func _process(delta: float) -> void: #TODO разобраться с функцией
	var count = mini(MESHES_PER_FRAME, pending_meshes.size()) # Берем либо весь массив, либо MESHES_PER_FRAME
	for i in range(count):
		var data = pending_meshes.pop_front()
		var sector_pos : Vector3i = data[0]
		var mesh : ArrayMesh = data[1]
		if sector_pos in sectors:
			sectors[sector_pos].apply_generated_mesh(mesh)

func set_block_global(collider: Sector, collision_point: Vector3, collision_normal: Vector3, block_name: StringName):
	const EPSILON = 0.001
	var target_point = collision_point
	if block_name == &"cora:void":
		target_point -= collision_normal * EPSILON
	else:
		target_point += collision_normal * EPSILON
	var local_pos = collider.to_local(target_point)
	var local_voxel_pos = Vector3i(
		floor(local_pos.x),
		floor(local_pos.y),
		floor(local_pos.z)
	)
	var global_voxel_pos: Vector3i = collider.sector_pos * SECTOR_SIZE + local_voxel_pos
	var target_sector_coord: Vector3i = Vector3i(
		floori(global_voxel_pos.x / float(SECTOR_SIZE)),
		floori(global_voxel_pos.y / float(SECTOR_SIZE)),
		floori(global_voxel_pos.z / float(SECTOR_SIZE))
	)
	var target_local_pos: Vector3i = global_voxel_pos - (target_sector_coord * SECTOR_SIZE)
	if target_sector_coord in sectors:
		sectors[target_sector_coord].set_block(target_local_pos.x, target_local_pos.y, target_local_pos.z, block_name)
	else:
		if block_name != &"cora:void":
			var new_sector = Sector.new()
			new_sector.name = "Sector_%s_%s_%s" % [target_sector_coord.x, target_sector_coord.y, target_sector_coord.z]
			new_sector.position = Vector3(
				target_sector_coord.x * SECTOR_SIZE,
				target_sector_coord.y * SECTOR_SIZE,
				target_sector_coord.z * SECTOR_SIZE
			)
			new_sector.sector_pos = target_sector_coord
			add_child(new_sector)
			sectors[target_sector_coord] = new_sector
			new_sector.init_buffer()
			new_sector.set_block(target_local_pos.x, target_local_pos.y, target_local_pos.z, block_name)

func generate(x1: int, y1: int, z1: int, x2: int, y2: int, z2: int, type: int) -> void:
	# ШАГ 1: Создаём все секторы синхронно (это быстро — просто узлы и массивы)
	for x in range(x1, x2):
		for y in range(y1, y2):
			for z in range(z1, z2):
				var sector : Sector = Sector.new()
				sector.name = "Sector_%s_%s_%s" % [x, y, z]
				sector.position = Vector3(x * SECTOR_SIZE, y * SECTOR_SIZE, z * SECTOR_SIZE)
				sector.sector_pos = Vector3i(x, y, z)
				add_child(sector)
				sectors[Vector3i(x, y, z)] = sector
				sector.init_buffer()
				sector.test_generate(type)

	# ШАГ 2: Запускаем генерацию мешей в фоновых потоках
	for x in range(x1, x2):
		for y in range(y1, y2):
			for z in range(z1, z2):
				# add_task отправляет функцию в пул потоков Godot
				# .bind() передаёт аргументы в эту функцию
				WorkerThreadPool.add_task(_generate_sector_mesh.bind(Vector3i(x, y, z)))

func _generate_sector_mesh(sector_pos: Vector3i) -> void:
	# ⚠️ ВНИМАНИЕ: Эта функция работает в другом потоке!
	# Здесь НЕЛЬЗЯ обращаться к узлам сцены (add_child, position и т.д.)

	var sector = sectors[sector_pos]
	var mesh = sector.generate_mesh_data()  # Считаем меш (это безопасно в потоке)

	# call_deferred откладывает вызов до главного потока
	call_deferred("_on_sector_mesh_generated", sector_pos, mesh)

func _on_sector_mesh_generated(sector_pos: Vector3i, mesh: ArrayMesh) -> void:
	# Просто кладём готовый меш в очередь
	pending_meshes.append([sector_pos, mesh])
