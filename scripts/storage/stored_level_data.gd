# дамп сохранения уровня с маппингом
class_name StoredLevelData

var _dict := {}

var bg_layer_data: PackedByteArray :
	set(value):
		_dict["bg_layer_data"] = value
	get:
		return _dict["bg_layer_data"]


var obstacle_layer_data: PackedByteArray :
	set(value):
		_dict["obstacle_layer_data"] = value
	get:
		return _dict["obstacle_layer_data"]


var player_position: Vector2 :
	set(value):
		_dict["player_position"] = value
	get:
		return _dict["player_position"]


var enemies_positions: Array[Vector2] :
	set(value):
		_dict["enemies_positions"] = value
	get:
		return _dict["enemies_positions"]
		

var coin_count: int :
	set(value):
		_dict["coin_count"] = value
	get:
		return _dict["coin_count"]


var player_speed: float :
	set(value):
		_dict["player_speed"] = value
	get:
		return _dict["player_speed"]


var enemy_speed: float :
	set(value):
		_dict["enemy_speed"] = value
	get:
		return _dict["enemy_speed"]


var max_coin_count: int :
	set(value):
		_dict["max_coin_count"] = value
	get:
		return _dict["max_coin_count"]


var coins_positions: Array[Vector2] :
	set(value):
		_dict["coins_positions"] = value
	get:
		return _dict["coins_positions"]


func _init(dict: Dictionary = {}) -> void:
	_dict = dict


func get_dict() -> Dictionary:
	return _dict


func is_valid() -> bool:
	return _dict != null and _dict.keys().size() > 0
