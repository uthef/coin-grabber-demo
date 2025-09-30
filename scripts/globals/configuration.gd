# узел для создания и загрузки конфигурационного файла
extends Node

@onready
var file_path := "user://config.ini"

const MAIN_SECTION := "Main"

const PLAYER_SPEED_KEY = "player_speed"
const ENEMY_SPEED_KEY = "enemy_speed"
const COIN_COUNT_KEY = "coin_count"

const DEFAULT_PLAYER_SPEED := 180.0
const DEFAULT_ENEMY_SPEED := 150.0
const DEFAULT_COIN_COUNT := 8

var file: ConfigFile = null


func _ready() -> void:
    if not FileAccess.file_exists(file_path):
        load_config_file()


func load_config_file() -> void:
    file = ConfigFile.new()
    file.load(file_path)

    # проверка наличия всех пар ключ-занчение
    var any_key_missing := false

    if not file.has_section_key(MAIN_SECTION, PLAYER_SPEED_KEY):
        file.set_value(MAIN_SECTION, PLAYER_SPEED_KEY, DEFAULT_PLAYER_SPEED)
        any_key_missing = true
    
    if not file.has_section_key(MAIN_SECTION, ENEMY_SPEED_KEY):
        file.set_value(MAIN_SECTION, ENEMY_SPEED_KEY, DEFAULT_ENEMY_SPEED)
        any_key_missing = true

    if not file.has_section_key(MAIN_SECTION, COIN_COUNT_KEY):
        file.set_value(MAIN_SECTION, COIN_COUNT_KEY, DEFAULT_COIN_COUNT)
        any_key_missing = true
    

    # сохранение недостающих пар
    if any_key_missing:
        file.save(file_path)


func get_player_speed() -> float:
    if file == null: load_config_file()
    return clampf(file.get_value(MAIN_SECTION, PLAYER_SPEED_KEY, DEFAULT_PLAYER_SPEED), 0.0, 300.0) 


func get_enemy_speed() -> float:
    if file == null: load_config_file()
    return clampf(file.get_value(MAIN_SECTION, ENEMY_SPEED_KEY, DEFAULT_ENEMY_SPEED), 0.0, 300.0)


func get_coin_count() -> int:
    if file == null: load_config_file()
    return clampi(file.get_value(MAIN_SECTION, COIN_COUNT_KEY, DEFAULT_COIN_COUNT), 1, 16)

