extends RefCounted
class_name Registry

var Packs : Array[Dictionary]
var Blocks : Dictionary
var Entities : Array[Entity_Data]
var Generators : Dictionary

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
			Packs.append({"pack_name" : manifest.name})
			name = manifest.name
			for i in resources.filter(func(res):return res is BlockData):
				Blocks[str("%s:%s" % [name,i.id])] = i
			for i in resources.filter(func(res):return res is GenerationData):
				Generators[str("%s:%s" % [name,i.name])] = i
		else:
			print("Отсутствует манифест.")
	else:
		print("Пак пустой.")
	print("Пак закрыт.")
