extends RefCounted
class_name FileManager

@export var engine_path : String

func scan_folder(path: String) -> Array:
	print("Инициализация сканирования папки с ресурсами. Проверка директории.")
	if path:
		print("Директория существует, открываем.")
		var dir = DirAccess.open(path)
		if dir:
			print("Открыли, читаем файлы.")
			var dirs = dir.get_directories(); print(dirs)
			if dirs:
				var import : Array
				for i in dirs:
					var dir2 = DirAccess.open("%s/%s" % [path,i])
					var files = dir2.get_files()
					for f in files:
						import.append(ResourceLoader.load("%s/%s/%s" % [path,i,f]))
				return import
			else: return []
		else:
			print("Директории не существует. Конец проверки.")
			return []
	else:
		print("Неправильный путь к директории или он отсутствует вовсе.")
		return []
