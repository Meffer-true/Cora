extends RefCounted
class_name WorldGenerator

var raw_data : GenerationData:
	set(v):
		if raw_data != null:
			if raw_data.match_script != "":
				var dynamic_script = GDScript.new()
				dynamic_script.source_code = "extends Resource\n\nfunc match_block(x:int,y:int,z:int):\n\t"
				dynamic_script.reload()
				runtime_data.set_script(dynamic_script)
var runtime_data : Resource

func _init() -> void:
	pass
