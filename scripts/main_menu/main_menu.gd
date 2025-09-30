# узел главного меню
extends Node

@onready 
var menu_items: Array[Node] = $CanvasLayer/Menu/MenuItems.get_children()

@onready 
var selected_menu_item: int = 0

var level_data: StoredLevelData = null


func _ready() -> void:
	# чтение файла сохранения
	level_data = DataSaveManager.read()

	if level_data.is_valid():
		# когда сохранение доступено, активируем первый пункт меню
		menu_items[0].enabled = true
		menu_items[0].highlight = true
	else:
		level_data = null

	# определение активного элемента меню
	var found_highlighted := false

	for i in menu_items.size():
		if menu_items[i].highlight:
			if found_highlighted:
				menu_items[i].highlight = false
				continue

			selected_menu_item = i
			found_highlighted = true


func _input(event: InputEvent) -> void:
	# обработка ввода пользователя
	var next_idx: int =  0

	if event.is_action_pressed("move_up"):
		next_idx = get_previous_menu_item_index(selected_menu_item)

		menu_items[selected_menu_item].highlight = false
		menu_items[next_idx].highlight = true
		selected_menu_item = next_idx
	elif event.is_action_pressed("move_down"):
		next_idx = get_next_menu_item_index(selected_menu_item)

		menu_items[selected_menu_item].highlight = false
		menu_items[next_idx].highlight = true
		selected_menu_item = next_idx
	elif event.is_action_pressed("ui_accept"):
		on_menu_item_selected()


func get_next_menu_item_index(idx: int) -> int:
	# поиск следующего доступного элемента меню
	var next_idx = clamp(idx + 1, 0, menu_items.size() - 1)

	while not menu_items[next_idx].enabled:
		next_idx += 1
		
		if next_idx >= menu_items.size():
			return idx

	return next_idx


func get_previous_menu_item_index(idx: int) -> int:
	# поиск предыдущего доступного элемента меню
	var next_idx = clamp(idx - 1, 0, menu_items.size() - 1)

	while not menu_items[next_idx].enabled:
		next_idx -= 1

		if next_idx < 0:
			return idx

	return next_idx


func on_menu_item_selected() -> void:
	var item_name: String = menu_items[selected_menu_item].name

	match item_name:
		"Continue":
			load_level()
		"NewGame":
			load_new_level()
		"Quit":
			get_tree().quit()


func load_new_level() -> void:
	Configuration.load_config_file()
	SceneManager.change_current_scene("res://scenes/level/level.tscn")


func load_level() -> void:
	SceneManager.change_current_scene("res://scenes/level/level.tscn", 
		{ 
			"level_data": level_data 
		}
	)
