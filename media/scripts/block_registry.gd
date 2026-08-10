extends RefCounted
class_name BlockRegistry

var Blocks : Array[BlockData]

func read_folder(path:String):
	print("Загрузка блоков")
	var dir = DirAccess.open(path)
	var files
	if dir:
		print("Директория существует")
		files = dir.get_files()
	else:
		print("Директории не существует")
	if files:
		for i in files:
			print(i)
			if ResourceLoader.exists("%s/%s" % [path,i]):
				print("%s/%s существует" % [path,i])
				Blocks.append(ResourceLoader.load("%s/%s" % [path,i]))
			else:
				print("%s/%s не существует" % [path,i])
		print("Загрузка блоков завершена, блоки - %s" % [Blocks])
