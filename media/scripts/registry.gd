extends RefCounted
class_name Registry

var Blocks : Array[BlockData]
var Entities : Array[Entity_Data]

var path : String

func scan_folder() -> void:
	print("Инициализация сканирования папки с ресурсами. Проверка директории.")
	if path:
		print("Директория существует, открываем.")
		var dir = DirAccess.open(path)
		if dir:
			var files
			print("Директория существует")
			files = dir.get_files()
			if files:
				for i in files:
					print(i)
					if ResourceLoader.exists("%s/%s" % [path,i]):
						print("%s/%s существует" % [path,i])
						Blocks.append(ResourceLoader.load("%s/%s" % [path,i]))
					else:
						print("%s/%s не существует" % [path,i])
			print("Загрузка блоков завершена, блоки - %s" % [Blocks])
		else:
			print("Директории не существует. Конец проверки.")
	else:
		print("Неправильный путь к директории или он отсутствует вовсе.")
		
