extends Node
class_name WorldManager

func generate(x1:int,y1:int,z1:int,x2:int,y2:int,z2:int):
	for x in abs(x2-x1):
		for y in abs(y2-y1):
			for z in abs(z2-z1):
				var sector = Sector.new()
				sector.position = Vector3((x-1)*10,(y-1)*10,(z-1)*10)
				add_child(sector)
				sector.init_buffer()
				sector.test_generate(1)
				sector.update()
