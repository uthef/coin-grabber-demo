# узел отвечает за генерацию карты, полигона навигации и монет, конфигурацию/расположение персонажей
@tool
class_name Level extends Node2D

@export
var map_size := Vector2i(50, 50)

var number_of_enemies := 4

@export_tool_button("Regenerate map")
var generate_map_bt_callable := generate_map

signal navigation_map_available(map_id: RID)
signal map_generated(data: StoredLevelData)

@onready 
var nav_region: NavigationRegion2D = $NavRegion

@onready
var bg_layer: TileMapLayer = $BackgroundLayer

@onready
var obstacle_layer: TileMapLayer = nav_region.get_node("ObstacleLayer")

@onready
var coin_scene: PackedScene = preload("res://scenes/level/coin/coin.tscn")

var min_obstacle_distance: int = 6

@onready
var max_coin_count := 8

var enemy_scene := preload("res://scenes/level/enemy/enemy.tscn")
var level_data: StoredLevelData = null

enum Pattern {
	GREEN_TREE1 = 0,
	GREEN_TREE2 = 1,
	GREEN_TREE3 = 2,
	PILLAR = 3,
	COLORED_TREE1 = 4,
	COLORED_TREE2 = 5,
	COLORED_TREE3 = 6
}

class ObstaclePosition:
	var value := Vector2.ZERO
	var taken := false

	func _init(pos) -> void:
		value = pos


func get_random_grass_tile_coord() -> Vector2i:
	return Vector2i(randi_range(0, 3), randi_range(0, 3))


func _ready() -> void:
	if Engine.is_editor_hint():
		generate_map()
		return 

	max_coin_count = $Player.max_coin_count
	$Player.movement_limits = Rect2(Vector2.ZERO, map_size * bg_layer.tile_set.tile_size)

	if level_data == null:
		$Player.max_coin_count = Configuration.get_coin_count()
		max_coin_count = Configuration.get_coin_count() 
		$Player.speed = Configuration.get_player_speed()
		$Player.collect_coin(0)

		generate_map()
		emit_signal("map_generated", store_level())
	else:
		load_level(level_data)
		level_data = null


# генерация ландшафта, запекание полигона навигации, расположение игрока и врагов
func generate_map():
	generate_background()
	var positions := generate_obstacles()
	generate_coins(positions)

	if Engine.is_editor_hint():
		return
	
	place_player(positions)
	place_enemies(positions)

	nav_region.bake_navigation_polygon()


func place_enemies(positions: Array[ObstaclePosition]) -> void:
	clear_enemies()

	for i in number_of_enemies:
		var pos_idx := randi() % positions.size()
		var pos = positions[pos_idx]

		place_enemy(pos.value, 3., Configuration.get_enemy_speed())
		swap_and_pop(positions, pos_idx)


# оптимизированная функция удаления элементов из массива без сдвига,
# для случаев, когда порядок элементов не имеет значения
func swap_and_pop(array: Array, idx: int) -> void:
	array[idx] = array[array.size() - 1]
	array.pop_back()


func place_enemy(pos: Vector2, activation_delay: float = 3., speed: float = 150.) -> void:
	var enemy: Enemy = enemy_scene.instantiate()
	enemy.position = pos
	enemy.speed = speed
	enemy.activation_delay = activation_delay

	navigation_map_available.connect(enemy._on_level_navigation_map_available)
	enemy.target_caught.connect($UILayer._on_enemy_target_caught)
	
	add_child(enemy)


func place_player(positions: Array[ObstaclePosition]) -> void:
	var pos_idx := randi() % positions.size()
	var player_pos := Vector2.ZERO if positions.size() < 1 else positions[pos_idx].value

	if player_pos.x == 0:
		player_pos.x += 40

	if player_pos.y == 0:
		player_pos.y += 40
	
	$Player.position = player_pos

	swap_and_pop(positions, pos_idx)


func generate_background():
	bg_layer.clear()

	# генерация фоновый травы
	for y in map_size.y:
		for x in map_size.x:
			var map_coords := Vector2i(y, x)

			# случайный тайл из области травы без цветочков
			var atlas_coords := get_random_grass_tile_coord()

			# с небольшим шансом тайл сдвигается в правую область 3x3
			# для добавления цветов
			if randf() <= 0.1:
				atlas_coords.x += 4

			bg_layer.set_cell(map_coords, 0, atlas_coords)


	# вычисление минимального и максимального количества участков
	# с каменными плитками в соответствии с размером карты
	var max_stone_regions_number := map_size.x * map_size.y / 40
	var min_stone_regions_number := maxi(2, max_stone_regions_number / 2)

	# генерация участков с каменными плитками
	for i in randi_range(min_stone_regions_number, max_stone_regions_number):
		# область для участка на карте
		var region := Rect2i(
			Vector2i(randi_range(0, map_size.x - 1), randi_range(0, map_size.y - 1)),
			Vector2i(randi_range(1, 7), randi_range(1, 7))
		)

		# заполнение области случайными тайлами каменных плиток
		for y in range(region.position.y, region.end.y):
			if y > map_size.y - 1: break

			for x in range(region.position.x, region.end.x):
				if x > map_size.x - 1: break
				# по координатам ставится случайный тайл плитки
				bg_layer.set_cell(Vector2i(x, y), 0, Vector2i(randi_range(0, 1), randi_range(4, 7)))


func generate_obstacles() -> Array[ObstaclePosition]:
	var positions: Array[ObstaclePosition] = []
	obstacle_layer.clear()

	# генерация препятствий
	for y in map_size.y / min_obstacle_distance:
		for x in map_size.x / min_obstacle_distance:
			var map_coord = Vector2i(x * min_obstacle_distance, y * min_obstacle_distance)

			# преобразование и сохранение координат для дальнейшего использования
			var obstacle_pos = ObstaclePosition.new(Vector2(map_coord * obstacle_layer.tile_set.tile_size))
			positions.push_back(obstacle_pos)

			if randf() > 0.7:
				continue

			obstacle_pos.taken = true

			# добавления препятствия
			var pattern_idx = randi() % 7
			map_coord += Vector2i(randi_range(0, 1), randi_range(0, 1))

			obstacle_layer.set_pattern(
				map_coord, 
				obstacle_layer.tile_set.get_pattern(pattern_idx)
			)

			# замена фонового тайла под стволом, чтобы деревья не росли
			# из каменных плиток
			if pattern_idx != Pattern.PILLAR:
				var trunk_pos = map_coord + Vector2i(1, 4)
				if pattern_idx in [Pattern.GREEN_TREE1, Pattern.COLORED_TREE1]: trunk_pos.x += 1

				bg_layer.set_cell(trunk_pos, 0, get_random_grass_tile_coord())
	

	return positions


func generate_coins(positions: Array[ObstaclePosition]) -> void:
	clear_coins()
	# генерация монет с использованием массива доступных позиций

	for i in max_coin_count:
		if positions.size() == 0:
			break
		
		var idx := randi() % positions.size()

		var obstacle_pos := positions[idx]

		var coin_instance = coin_scene.instantiate()
		coin_instance.position = obstacle_pos.value

		var tile_size := obstacle_layer.tile_set.tile_size

		# сдвиг позиции вправо
		coin_instance.position += Vector2(randi() % (min_obstacle_distance - 1), 0) * Vector2(tile_size.x, 0)

		# свдиг вниз, если под монетой ничего нет
		if not obstacle_pos.taken:
			coin_instance.position += Vector2(0, randi() % (min_obstacle_distance - 1)) * Vector2(0, tile_size.y)

		add_child(coin_instance)

		# удаляем позицию из массива во избежание её повторного выпадания
		swap_and_pop(positions, idx)


func clear_coins() -> void:
	for node: Area2D in get_tree().get_nodes_in_group("coins"):
		node.queue_free()


func clear_enemies() -> void:
	for node: Enemy in get_tree().get_nodes_in_group("enemies"):
		node.queue_free()


# выгрузка дампа уровня
func store_level() -> StoredLevelData:
	var data := StoredLevelData.new()

	data.bg_layer_data = bg_layer.tile_map_data
	data.obstacle_layer_data = obstacle_layer.tile_map_data

	data.player_position = $Player.position
	data.coin_count = $Player.coin_count
	data.max_coin_count = $Player.max_coin_count
	data.player_speed = $Player.speed

	data.enemies_positions = []
	data.coins_positions = []

	for enemy: Enemy in get_tree().get_nodes_in_group("enemies"):
		data.enemies_positions.push_back(enemy.position)
		data.enemy_speed = enemy.speed

	for coin: Area2D in get_tree().get_nodes_in_group("coins"):
		data.coins_positions.push_back(coin.position)
	
	return data
	

# загрузка дампа уровня
func load_level(data: StoredLevelData) -> void:
	bg_layer.clear()
	obstacle_layer.clear()
	clear_coins()
	clear_enemies()

	if not data.is_valid():
		push_error("Invalid save file")
		SceneManager.change_current_scene("res://scenes/main_menu/main_menu.tscn")
		return

	bg_layer.tile_map_data = data.bg_layer_data
	obstacle_layer.tile_map_data = data.obstacle_layer_data

	$Player.position = data.player_position
	$Player.max_coin_count = data.max_coin_count
	$Player.collect_coin(data.coin_count)
	$Player.speed = data.player_speed

	for coin_pos: Vector2 in data.coins_positions:
		var coin_instance: Area2D = coin_scene.instantiate()
		coin_instance.position = coin_pos
		add_child(coin_instance)

	for enemy_pos: Vector2 in data.enemies_positions:
		place_enemy(enemy_pos, .5, data.enemy_speed)
	
	nav_region.bake_navigation_polygon()


func _on_nav_region_bake_finished() -> void:
	if Engine.is_editor_hint(): return
	emit_signal("navigation_map_available", nav_region.get_navigation_map())


# остановка игры по сигналу от UI
func _on_ui_layer_game_state_changed(paused: bool) -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED if paused else Node.PROCESS_MODE_INHERIT
