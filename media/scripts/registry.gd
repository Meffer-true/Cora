extends RefCounted
class_name Registry

var Packs : Array[Dictionary]
var Blocks : Dictionary
var Entities : Array[Entity_Data]
var Generators : Array[GenerationData]

var path : String

func filter(resources : Array) -> void:
	print("Получен пак.")
	if resources != []:
		print("Пак открыт.")
		print(resources)
		var has_manifest = resources.any(func(res): return res is Manifest)
		var name : StringName
		print(has_manifest)
		if has_manifest:
			print("Читаем манифест.")
			var manifest : Manifest = resources.filter(func(res):return res is Manifest)[0]
			name = manifest.name
			for i in resources.filter(func(res):return res is BlockData):
				Blocks[str("%s:%s" % [name,i.id])] = i
		else:
			print("Отсутствует манифест.")
	else:
		print("Пак пустой.")
	print("Пак закрыт.")

func scan_folder() -> void:
	print("Инициализация сканирования папки с ресурсами. Проверка директории.")
	if path:
		print("Директория существует, открываем.")
		var dir = DirAccess.open(path)
		if dir:
			print("Открыли, читаем файлы.")
			var dirs = dir.get_directories(); print(dirs)
			if dirs:
				for i in dirs:
					var dir2 = DirAccess.open("%s/%s" % [path,i])
					var files = dir2.get_files()
					var import : Array
					for f in files:
						import.append(ResourceLoader.load("%s/%s/%s" % [path,i,f]))
					filter(import)
					#var has_manifest = import.any(func(res): return res is Manifest)
					#if has_manifest:
					#	for f in files:
					#		filter(ResourceLoader.load("%s/%s/%s" % [path,i,f]))
					#else:
					#	print("Манифест отсутствует.")
		else:
			print("Директории не существует. Конец проверки.")
	else:
		print("Неправильный путь к директории или он отсутствует вовсе.")

##GARBAGE
#match object:
	#	var r when r is BlockData:
	#		print("Это блок.")
	#		Blocks.append(object)
	#	var r when r is GenerationData:
	#		print("Это файл генератора.")
	#		Generators.append(object)
	#	_:
	#		print("Неизвестный тип ресурса. Пропускаем.")
