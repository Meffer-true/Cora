extends Node3D



func _ready() -> void:
	for x in 10:
		for y in 3:
			for z in 10:
				var sector = Sector.new()
				var type : int
				sector.position = Vector3((x-1) * 10, (y-1)*10, (z-1) * 10)
				sector.scale = Vector3(1,1,1)
				add_child(sector)
				if y == 0:
					type = 1
				elif y == 1:
					type = 0
				elif y == 2:
					type = 1
				sector.test_generate(type)
				print("Sector [%s,%s,%s] is made! It's type is %s" % [x,y,z,type])
				sector.update()
	
