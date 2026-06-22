extends RefCounted
class_name BlockRegistry


var _blocks: Dictionary[int, BlockData] = {}
var _by_name: Dictionary[StringName, BlockData] = {}

func register(data: BlockData) -> void:
	if _blocks.has(data.id):
		push_error("Block ID %d already registered!" % data.id)
		return
	_blocks[data.id] = data
	_by_name[data.name] = data

func get_by_id(id: int) -> BlockData:
	return _blocks.get(id)

func get_by_name(block_name: StringName) -> BlockData:
	return _by_name.get(block_name)

func get_all_blocks() -> Array[BlockData]:
	return _blocks.values()
