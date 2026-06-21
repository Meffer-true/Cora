extends Node
class_name WorldManager

@export var sectors : Dictionary[Vector3i, Sector] = {}
const SECTOR_SIZE = 10

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
		# Сектор уже существует, просто ставим/ломаем блок
		sectors[target_sector_coord].set_block(target_local_pos.x, target_local_pos.y, target_local_pos.z, block_id)
	else:
		# Сектора нет. Если мы пытаемся поставить блок (block_id != 0) -> создаем его!
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
			# set_block сам внутри вызовет update() для пересборки меши
			new_sector.set_block(target_local_pos.x, target_local_pos.y, target_local_pos.z, block_id)
		else:
			# Пытаемся сломать блок в несуществующем секторе (там и так воздух, ничего не делаем)
			pass

func generate(x1: int, y1: int, z1: int, x2: int, y2: int, z2: int, type: int) -> void:
	for x in range(x1, x2):
		for y in range(y1, y2):
			for z in range(z1, z2):
				var sector = Sector.new()
				sector.name = "Sector_%s_%s_%s" % [x, y, z]
				sector.position = Vector3(x * SECTOR_SIZE, y * SECTOR_SIZE, z * SECTOR_SIZE)
				sector.sector_pos = Vector3i(x, y, z)
				add_child(sector)
				sectors.set(Vector3i(x, y, z), sector)
				sector.init_buffer()
				sector.test_generate(type)
				sector.update()
