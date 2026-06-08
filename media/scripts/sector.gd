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

func test_generate() -> void:
	for x in SIZE:
		for y in SIZE:
			for z in SIZE:
				var idx : int = _get_index(x, y, z)
				if y <= 4:
					blocks[idx] = 1
				elif y > 4:
					blocks[idx] = 2

func _create_face(st: SurfaceTool, pos: Vector3, direction: Vector3i) -> void:
	var face_info = FACE_DATA[direction]
	st.set_normal(face_info["normal"])
	for vertex_offset in face_info["vertices"]:
		st.add_vertex(pos + vertex_offset)

func update():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var green_material = StandardMaterial3D.new()
	var gray_material = StandardMaterial3D.new()
	green_material.albedo_color = Color(0.2, 0.6, 0.2)
	gray_material.albedo_color = Color(0.6, 0.6, 0.6, 1.0)
	#st.set_material(material)
	
	for x in SIZE:
		for y in SIZE:
			for z in SIZE:
				var block_id = _get_block_id(x,y,z)
				if block_id != 0:
					if block_id == 1:
						st.set_material(gray_material)
					elif block_id == 2:
						st.set_material(green_material)
					var block_pos = Vector3(x, y, z)
					print("Id is %s, then material is " % [block_id])
					for dir_key in FACE_DATA.keys():
						var neighbor_x = x + dir_key.x
						var neighbor_y = y + dir_key.y
						var neighbor_z = z + dir_key.z
						
						# Если сосед — воздух, рисуем грань
						if _get_block_id(neighbor_x, neighbor_y, neighbor_z) == 0:
							_create_face(st, block_pos, dir_key)
							
	var array_mesh = st.commit()
	mesh_instance.mesh = array_mesh
	
	if array_mesh.get_surface_count() > 0:
		collision_shape.shape = array_mesh.create_trimesh_shape()
	print(str(name) + "'s updated.")
