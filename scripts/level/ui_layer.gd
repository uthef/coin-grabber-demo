# узел отвечает за состояние игры и пользовательский интерфейс
extends CanvasLayer

var game_paused: bool = false :
	set(value):
		game_paused = value
		emit_signal("game_state_changed", game_paused)
	get:
		return game_paused


signal game_state_changed(paused: bool)

@onready
var coin_counter_label: Label = $CoinCounter

@onready
var greyscale_blur_shader: ColorRect = $GreyscaleBlurShader

@onready
var greyscale_blur_shader_material: ShaderMaterial = greyscale_blur_shader.material

@onready 
var message_container: VBoxContainer = $MessageContainer

@onready 
var level_node: Level = get_parent()

var game_ended := false


func _ready() -> void:
	# получение игрока для отображения кол-ва монет
	for node in get_tree().get_nodes_in_group("player"):
		var player := node as Player
		player.coin_count_changed.connect(update_coin_counter_label)
		break


# обновление счётчика монет
func update_coin_counter_label(value, max_value) -> void:
	coin_counter_label.text = "Монет собрано: %d/%d" % [value, max_value]

	if value >= max_value:
		game_ended = true
		show_message("Победа!", "Все монеты найдены. Нажмите ESC, чтобы вернуться в меню", Color.GREEN)
		DataSaveManager.clear()
	elif value > 0:
		DataSaveManager.write(level_node.store_level())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		greyscale_blur_shader_material.set_shader_parameter("strength", 0.0)

		if not game_ended: 
			DataSaveManager.write(level_node.store_level())

		load_menu()


func show_message(header: String, text: String, header_color: Color) -> void:
	# отображение сообщения на экране

	var header_label: Label = message_container.get_node("Header")
	header_label.text = header
	header_label.add_theme_color_override("font_color", header_color)
	message_container.get_node("Text").text = text

	message_container.scale = Vector2.ZERO
	message_container.rotation = PI / 4
	message_container.visible = true
	message_container.pivot_offset = message_container.size / 2.0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(message_container, "scale", Vector2(1, 1), .4)
	tween.tween_property(message_container, "rotation", 0, .4)
	tween.tween_property(greyscale_blur_shader, "material:shader_parameter/strength", 1.0, .4)
	tween.finished.connect(func(): game_paused = true)
	tween.play()


func _on_enemy_target_caught() -> void:
	game_ended = true
	show_message("Поражение", "Игровой персонаж был пойман. Нажмите ESC, чтобы вернуться в меню", Color.RED)
	DataSaveManager.clear()


func load_menu() -> void:
	SceneManager.change_current_scene("res://scenes/main_menu/main_menu.tscn")


func _on_level_map_generated(data: StoredLevelData) -> void:
	DataSaveManager.write(data)
