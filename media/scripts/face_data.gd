extends RefCounted
class_name FaceData

const FACE_DATA : Dictionary = { # Карта вершин для построения сторон. Строим тре-ки против часовой стрелки
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
