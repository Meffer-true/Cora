extends Node
class_name WorldManager

@export var sectors : Dictionary[Vector3i,Sector] = {}

const SECTOR_SIZE = 10

func set_block_global(collider:Sector, collision_point:Vector3, collision_normal:Vector3, block_id:int):
	# 1. Сдвигаем точку. 
	# Если ломаем (block_id == 0) - сдвигаем ВНУТРЬ блока (против нормали).
	# Если ставим (block_id != 0) - сдвигаем НАРУЖУ (по нормали).
	const EPSILON = 0.001
	var target_point = collision_point
	if block_id == 0:
		target_point -= collision_normal * EPSILON
	else:
		target_point += collision_normal * EPSILON

	# 2. Переводим сдвинутую точку в локальные координаты сектора
	var local_pos = collider.to_local(target_point)

	# 3. КРИТИЧЕСКИ ВАЖНО: Округляем ВНИЗ (floor), чтобы получить целочисленный индекс вокселя
	var voxel_pos = Vector3i(
		floor(local_pos.x), 
		floor(local_pos.y), 
		floor(local_pos.z)
	)

	# 4. Проверяем, попали ли мы внутрь текущего сектора
	if collider._is_inside(voxel_pos.x, voxel_pos.y, voxel_pos.z):
		collider.set_block(voxel_pos.x, voxel_pos.y, voxel_pos.z, block_id)
	else:
		# Если мы ставим блок и он выходит за границы текущего сектора 
		# (значит, мы ставим его в соседний сектор). 
		# Пока просто логируем, в будущем здесь будет создание нового сектора.
		print("WM: Взаимодействие за границами сектора %s. Локальные координаты: %s" % [collider.sector_pos, voxel_pos])

func generate(x1:int,y1:int,z1:int,x2:int,y2:int,z2:int,type:int):
	for x in range(x1, x2):  # Правильный диапазон
		for y in range(y1, y2):
			for z in range(z1, z2):
				var sector = Sector.new()
				sector.position = Vector3(x*10, y*10, z*10)
				sector.sector_pos = Vector3i(x,y,z)
				add_child(sector)
				sectors.set(Vector3i(x,y,z), sector)
				sector.init_buffer()
				sector.test_generate(type)
				sector.update()
