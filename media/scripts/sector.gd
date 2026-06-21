extends StaticBody3D
class_name Sector

const SIZE = 10

# Правильная карта вершин (все полигоны развернуты наружу (CCW) и привязаны к своим осям)
const FACE_DATA: Dictionary = {
	Vector3i.UP: {
		"normal": Vector3.UP,
		"vertices": [
			Vector3(0, 1, 1), Vector3(1, 1, 0), Vector3(1, 1, 1),
			Vector3(0, 1, 1), Vector3(0, 1, 0), Vector3(1, 1, 0)
		]
	},
	Vector3i.DOWN: {
		"normal": Vector3.DOWN,
		"vertices": [
			Vector3(0, 0, 0), Vector3(1, 0, 1), Vector3(1, 0, 0),
			Vector3(0, 0, 0), Vector3(0, 0, 1), Vector3(1, 0, 1)
		]
	},
	Vector3i.FORWARD: {
		"normal": Vector3.FORWARD,
		"vertices": [
			Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 0),
			Vector3(1, 0, 0), Vector3(1, 1, 0), Vector3(0, 1, 0)
		]
	},
	Vector3i.BACK: {
		"normal": Vector3.BACK,
		"vertices": [
			Vector3(0, 0, 1), Vector3(1, 1, 1), Vector3(1, 0, 1),
			Vector3(0, 0, 1), Vector3(0, 1, 1), Vector3(1, 1, 1)
		]
	},
	Vector3i.RIGHT: {
		"normal": Vector3.RIGHT,
		"vertices": [
			Vector3(1, 0, 1), Vector3(1, 1, 0), Vector3(1, 0, 0),
			Vector3(1, 0, 1), Vector3(1, 1, 1), Vector3(1, 1, 0)
		]
	},
	Vector3i.LEFT: {
		"normal": Vector3.LEFT,
		"vertices": [
			Vector3(0, 0, 0), Vector3(0, 1, 1), Vector3(0, 0, 1),
			Vector3(0, 0, 0), Vector3(0, 1, 0), Vector3(0, 1, 1)
		]
	}
}

var sector_pos : Vector3i
var blocks : Array[int] = []

var mesh_instance: MeshInstance3D 
var collision_shape: CollisionShape3D

func _ready() -> void:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.277, 0.333, 1.0, 0.196)
	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	collision_shape = CollisionShape3D.new()
	add_child(collision_shape)
	init_buffer()

func init_buffer():
	blocks.resize(SIZE * SIZE * SIZE)
	blocks.fill(0)

func _get_index(x: int, y: int, z: int):
	return x + (y * SIZE) + (z * SIZE * SIZE)

func _is_inside(x: int, y: int, z: int) -> bool:
	return x >= 0 and x < SIZE and y >= 0 and y < SIZE and z >= 0 and z < SIZE

func _get_block_id(x: int, y: int, z: int) -> int:
	if _is_inside(x, y, z):
		return blocks[_get_index(x, y, z)]
	return 0

func set_block(x: int, y: int, z: int, block_id: int) -> void:
	print("S: Начинаем установку блока.")
	if !_is_inside(x, y, z): # Проверка границ сектора 
		print("Блок вне границ сектора!")
	else:
		print("Блок в границах сектора.")
		var idx = _get_index(x, y, z) # Получение индекса 1D массива 
		if blocks[idx] != block_id:
			blocks[idx] = block_id
			update() # Запуск пересборки геометрии

func test_generate(type:int) -> void:
	for x in SIZE:
		for y in SIZE:
			for z in SIZE:
				var idx : int = _get_index(x, y, z)
				if type == 0:
					blocks[idx] = 0
				elif type == 1:
					if y <= 4:
						blocks[idx] = 1
					elif y > 4:
						blocks[idx] = 2

func _create_face(st: SurfaceTool, pos: Vector3, direction: Vector3i, color: Color) -> void:
	var face_info = FACE_DATA[direction]
	st.set_normal(face_info["normal"])
	
	# Устанавливаем цвет перед добавлением вершин. 
	# SurfaceTool применит этот цвет ко всем вершинам, добавленным ниже.
	st.set_color(color) 
	
	for vertex_offset in face_info["vertices"]:
		st.add_vertex(pos + vertex_offset)

func update():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Создаем ОДИН материал для всего чанка
	var chunk_material = StandardMaterial3D.new()
	# КРИТИЧЕСКИ ВАЖНО: говорим материалу использовать цвет из вершин, а не игнорировать его
	chunk_material.vertex_color_use_as_albedo = true
	st.set_material(chunk_material)
	
	for x in SIZE:
		for y in SIZE:
			for z in SIZE:
				var block_id = _get_block_id(x, y, z)
				if block_id != 0:
					var block_color : Color
					if block_id == 1:
						block_color = Color(1.0, 0.0, 0.0, 1.0)
					elif block_id == 2:
						block_color = Color(1.0, 1.0, 1.0, 1.0)
					var block_pos = Vector3(x, y, z)
					for dir_key in FACE_DATA.keys():
						var neighbor_x = x + dir_key.x
						var neighbor_y = y + dir_key.y
						var neighbor_z = z + dir_key.z
						if _get_block_id(neighbor_x, neighbor_y, neighbor_z) == 0:
							_create_face(st, block_pos, dir_key, block_color)
	var array_mesh = st.commit()
	if mesh_instance != null:
		mesh_instance.mesh = array_mesh
		if array_mesh.get_surface_count() > 0:
			collision_shape.shape = array_mesh.create_trimesh_shape()
			print(str(name) + "'s updated.")
	else:
		push_error("Mesh_i is empty!")
	
