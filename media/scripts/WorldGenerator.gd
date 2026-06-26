extends RefCounted
class_name WorldGenerator

# Ссылка на настройки (наш .tres файл)
var settings: GenerationData
# Ссылка на реестр блоков, чтобы переводить строковые ID в числа
var registry: BlockRegistry
# Встроенный генератор шума Godot
var noise: FastNoiseLite 

# =====================================================================
# === ЧТО ЭТО ДЕЛАЕТ: Конструктор ===
# Вызывается при создании объекта. Принимает настройки и реестр.
# =====================================================================
func _init(p_settings: GenerationData, p_registry: BlockRegistry) -> void:
	settings = p_settings
	registry = p_registry
	
	# Настраиваем шум на основе параметров из нашего .tres ресурса
	noise = FastNoiseLite.new()
	noise.seed = settings.seed
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX # simplex лучше подходит для ландшафта, чем perlin
	noise.frequency = settings.noise_frequency
	noise.fractal_octaves = settings.noise_octaves

# =====================================================================
# === ЧТО ЭТО ДЕЛАЕТ: Главная функция получения блока ===
# Принимает глобальные координаты (X, Y, Z) и возвращает ЧИСЛОВОЙ ID блока.
# =====================================================================
func get_block_at(global_pos: Vector3i) -> int:
	var x = global_pos.x
	var y = global_pos.y
	var z = global_pos.z

	# 1. Считаем высоту поверхности в этой конкретной колонке (X, Z)
	var surface_y = _get_surface_height(x, z)

	# 2. Логика определения блока по высоте (Y)
	
	# Если мы ниже уровня бедрока -> всегда бедрок
	if y <= settings.bedrock_level:
		return registry.get_id(settings.bedrock_block_id)
		
	# Если мы выше поверхности
	if y > surface_y:
		# Если выше поверхности, но ниже уровня моря -> жидкость (вода)
		if y <= settings.sea_level:
			return registry.get_id(settings.fluid_block_id)
		# Иначе -> воздух (ID 0)
		return 0 
		
	# Если мы ровно на поверхности
	if y == surface_y:
		# Под водой поверхность обычно песчаная/гравийная, поэтому используем subsurface
		if y <= settings.sea_level:
			return registry.get_id(settings.subsurface_block_id)
		# На суше -> верхний блок (трава)
		return registry.get_id(settings.surface_block_id)
		
	# Если мы внутри "грязной" прослойки под поверхностью
	if y > surface_y - settings.dirt_layer_thickness:
		return registry.get_id(settings.subsurface_block_id)
		
	# Во всех остальных случаях (глубоко внутри) -> камень
	return registry.get_id(settings.underground_block_id)

# =====================================================================
# === ЧТО ЭТО ДЕЛАЕТ: Вспомогательная функция для расчета высоты ===
# =====================================================================
func _get_surface_height(x: int, z: int) -> int:
	# get_noise_2d возвращает значение от -1.0 до 1.0
	var noise_val = noise.get_noise_2d(float(x), float(z))
	# Умножаем на амплитуду и прибавляем базовую высоту
	return int(settings.base_height + noise_val * settings.height_amplitude)
