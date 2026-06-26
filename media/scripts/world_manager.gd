extends Node
class_name WorldManager

@export var Gdata : GenerationData
@export var sectors : Dictionary[Vector3i, Sector] = {}
const SECTOR_SIZE = 10

# === НОВОЕ: Очередь для применения мешей ===
# Фоновые потоки складывают сюда готовые меши,
# а главный поток по чуть-чуть их применяет.
var pending_meshes : Array = []
const MESHES_PER_FRAME = 20  # Сколько секторов применять за один кадр


# === НОВОЕ: Выполняется каждый кадр в главном потоке ===
func _process(delta: float) -> void:
	# Берём из очереди не все меши сразу, а по MESHES_PER_FRAME штук
	var count = mini(MESHES_PER_FRAME, pending_meshes.size())
	for i in range(count):
		var data = pending_meshes.pop_front()
		var sector_pos : Vector3i = data[0]
		var mesh : ArrayMesh = data[1]
		if sector_pos in sectors:
			sectors[sector_pos].apply_generated_mesh(mesh)


func set_block_global(collider: Sector, collision_point: Vector3, collision_normal: Vector3, block_id: int) -> void:
	# 1. Сдвигаем точку по нормали
	const EPSILON = 0.001
	var target_point = collision_point
	if block_id == 0:
		target_point -= collision_normal * EPSILON
	else:
		target_point += collision_normal * EPSILON

	# 2. Переводим в локальные координаты ТЕКУЩЕГО сектора и округляем вниз
	var local_pos = collider.to_local(target_point)
	var local_voxel_pos = Vector3i(
		floor(local_pos.x), 
		floor(local_pos.y), 
		floor(local_pos.z)
	)

	# 3. Вычисляем ГЛОБАЛЬНЫЕ координаты вокселя
	var global_voxel_pos: Vector3i = collider.sector_pos * SECTOR_SIZE + local_voxel_pos

	# 4. Вычисляем, в какой СЕКТОР мы на самом деле попали
	var target_sector_coord: Vector3i = Vector3i(
		floori(global_voxel_pos.x / float(SECTOR_SIZE)),
		floori(global_voxel_pos.y / float(SECTOR_SIZE)),
		floori(global_voxel_pos.z / float(SECTOR_SIZE))
	)

	# 5. Вычисляем ЛОКАЛЬНЫЕ координаты внутри ЦЕЛЕВОГО сектора
	var target_local_pos: Vector3i = global_voxel_pos - (target_sector_coord * SECTOR_SIZE)

	# 6. Ищем целевой сектор
	if target_sector_coord in sectors:
		sectors[target_sector_coord].set_block(target_local_pos.x, target_local_pos.y, target_local_pos.z, block_id)
	else:
		if block_id != 0:
			print("WM: Создание нового сектора %s" % target_sector_coord)
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
			new_sector.set_block(target_local_pos.x, target_local_pos.y, target_local_pos.z, block_id)
		else:
			pass


# === ОБНОВЛЁННАЯ ФУНКЦИЯ: Теперь генерирует асинхронно ===
func generate(x1: int, y1: int, z1: int, x2: int, y2: int, z2: int, type: int) -> void:
	# ШАГ 1: Создаём все секторы синхронно (это быстро — просто узлы и массивы)
	for x in range(x1, x2):
		for y in range(y1, y2):
			for z in range(z1, z2):
				var sector = Sector.new()
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


# === НОВАЯ ФУНКЦИЯ: Выполняется в ФОНОВОМ ПОТОКЕ ===
func _generate_sector_mesh(sector_pos: Vector3i) -> void:
	# ⚠️ ВНИМАНИЕ: Эта функция работает в другом потоке!
	# Здесь НЕЛЬЗЯ обращаться к узлам сцены (add_child, position и т.д.)
	
	var sector = sectors[sector_pos]
	var mesh = sector.generate_mesh_data()  # Считаем меш (это безопасно в потоке)
	
	# call_deferred откладывает вызов до главного потока
	call_deferred("_on_sector_mesh_generated", sector_pos, mesh)


# === НОВАЯ ФУНКЦИЯ: Колбэк, выполняется в ГЛАВНОМ ПОТОКЕ ===
func _on_sector_mesh_generated(sector_pos: Vector3i, mesh: ArrayMesh) -> void:
	# Просто кладём готовый меш в очередь
	pending_meshes.append([sector_pos, mesh])
