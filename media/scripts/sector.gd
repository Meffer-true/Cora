extends StaticBody3D
class_name Sector

const SIZE = 10 # Размер грани сектора в блоках

var FACE_DATA = FaceData.new().FACE_DATA # Словарь с правильным построением сторон куба
var block_palette : Array[StringName] # Палитра блоков отдельного сектора. Позволяет хранить сами блоки в формате цифр
var blocks : Array[int] # Блоки отдельного сектора

var mesh_instance: MeshInstance3D # Будущий контейнер для всех текстур, пока что просто уточняем тип
var collision_shape: CollisionShape3D # Будущий контейнер для всех коллизий, пока что просто уточняем тип

func _ready() -> void:
	mesh_instance = MeshInstance3D.new() # Добавляем сам объект будущей текстуры в переменную
	add_child(mesh_instance) # Добавляем его в древо нод
	collision_shape = CollisionShape3D.new() # Добавляем сам объект будущей коллизии в переменную
	add_child(collision_shape) # Добавляем его в древо нод
	init_buffer() # Наполняем объект пустотой, чтобы не возникало ошибок при взаимодействии с ним
	block_palette[0] = "cora:void"
func init_buffer(): # Функция для заполнения сектора пустыми блоками
	blocks.resize(SIZE * SIZE * SIZE)
	blocks.fill(0)

func _get_index(x: int, y: int, z: int): # Вспомогательная функция для получения индекса в одномерном массиве
	return x + (y * SIZE) + (z * SIZE * SIZE)

func is_inside(x: int, y: int, z: int) -> bool: # Вспомогательная функция для понимания где находится блок
	return x >= 0 and x < SIZE and y >= 0 and y < SIZE and z >= 0 and z < SIZE

func get_block_id(x: int, y: int, z: int) -> int: # Функция для безопасного получения айди блока
	if is_inside(x,y,z):
		return blocks[_get_index(x,y,z)]
	else:
		return 0

func get_block(x: int, y: int, z: int) -> BlockData: # Функция для получения блока в формате BlockData
	var block_id = get_block_id(x,y,z)
	if block_id != 0:
		return Global.Reg.Blocks[block_palette[block_id]]
	else:
		return load("res://media/default_resources/null_block.tres")

func set_block(x: int, y: int, z: int, block_name: StringName) -> void: # Функция для установки блока (кэп оч)
	if is_inside(x,y,z): # Проверяем находится ли запрашиваемый блок в этом секторе
		var idx = _get_index(x,y,z) # Превращаем 3х мерные координату в одномерную одну
		var block_id : int # Заранее объявляем переменную для всей функции под цифровой идентификатор блока
		if block_name not in block_palette: # Если буквенного идентификатора блока еще нет в палитре..
			block_palette.append(block_name) # .., то добавляем его
			block_id = block_palette.size()-1 # и берем уже цифровой идентификатор
		else:
			block_id = block_palette.find(block_name) # Просто находим цифровой идентификатор блока
		if block_id != blocks[idx]: # Если на запрашиваемом месте еще не стоит этого блока..
			blocks[idx] = block_id # .., то ставим его
			apply_generated_mesh(generate_mesh_data()) # И обновляем весь чанк
		else:
			print("Ну, тут уже есть этот блок. Зачем ставить дважды?")
	else:
		print("Запрашиваемый блок находится вообще не здесь!!!")

func create_face(st: SurfaceTool, pos: Vector3, direction: Vector3i, color: Color) -> void: # Функция для отрисовки отдельных плиток (сторон блоков, не сектора)
	var face_info = FACE_DATA[direction]
	st.set_normal(face_info["normal"])
	st.set_color(color)
	for vertex_offset in face_info["verticles"]:
		st.add_vertex(pos + vertex_offset)

func test_generate(type):
	if type == 0:
		blocks.fill(0)
	else:
		pass

func generate_mesh_data() -> ArrayMesh: # Функция для конечной сборки текстуры сектора
	var st = SurfaceTool.new() # Создаем новый ST, с помощью которого будем шить наши текстурки
	st.begin(Mesh.PRIMITIVE_TRIANGLES) #TODO сделать описания каждой строчке, мне щас лень пиздец
	var chunk_material = StandardMaterial3D.new()
	chunk_material.vertex_color_use_as_albedo = true
	st.set_material(chunk_material)
	for x in SIZE: for y in SIZE: for z in SIZE: # Тривложенный цикл для прохода по всему сектору
		var block_id = get_block_id(x,y,z)
		if block_id != 0:
			var block_color = Global.Reg.Blocks[block_palette[block_id]].color
			var block_pos = Vector3(x,y,z)
			for dir_key in FACE_DATA.keys():
				var neighbor_x = x + dir_key.x
				var neighbor_y = y + dir_key.y
				var neighbor_z = z + dir_key.z
				if get_block_id(neighbor_x, neighbor_y, neighbor_z) == 0:
					create_face(st, block_pos, dir_key, block_color)
	return st.commit()

func apply_generated_mesh(mesh: ArrayMesh) -> void: # 
	if mesh_instance != null:
		mesh_instance.mesh = mesh
		if mesh.get_surface_count() > 0:
			collision_shape.shape = mesh.create_trimesh_shape()
			print(str(name) + "'s updated.")
		else:
			print("Mesh is empty")
