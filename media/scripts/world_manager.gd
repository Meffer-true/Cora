extends Node
class_name WorldManager

@export var sectors : Dictionary[Vector3i,Sector] = {}

func set_block_global(global_pos:Vector3i,block_id:int):
	print("WM: Начинаем установку блока.")
	var sector_pos = global_pos / 10
	var local_pos = Vector3i()
	local_pos.x = posmod(global_pos.x,10)
	local_pos.y = posmod(global_pos.y,10)
	local_pos.z = posmod(global_pos.z,10)
	#print("Global position (%s,%s,%s), sector position (%s,%s,%s), local position (%s,%s,%s)" % [global_pos.x,global_pos.y,global_pos.z,sector_pos.x,sector_pos.y,sector_pos.z,local_pos.x,local_pos.y,local_pos.z])
	if sector_pos in sectors:
		print("WM: Сектор обнаружен в списке.")
		var current_sector : Sector = sectors[sector_pos]
		current_sector.set_block(local_pos.x,local_pos.y,local_pos.z,0)
	else:
		print("WM: Сектор (%s) не обнаружен в списке. Список секторов:" % [sector_pos])
		print(sectors)

func generate(x1:int,y1:int,z1:int,x2:int,y2:int,z2:int):
	for x in abs(x2-x1):
		for y in abs(y2-y1):
			for z in abs(z2-z1):
				var sector = Sector.new()
				sector.position = Vector3((x-1)*10,(y-1)*10,(z-1)*10)
				add_child(sector)
				sectors.set(Vector3i(x,y,z),sector)
				sector.init_buffer()
				sector.test_generate(1)
				sector.update()
