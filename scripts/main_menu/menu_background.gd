extends Node2D


var coin_scene: PackedScene = preload("res://scenes/main_menu/coin.tscn")
var coin_appearance_interval := .15
var time := coin_appearance_interval


func _process(delta: float) -> void:
    if time >= coin_appearance_interval:
        place_coin()
        time = 0
        return

    time += delta


func place_coin() -> void:
    var coin: AnimatedSprite2D = coin_scene.instantiate()
    coin.position = Vector2(randf_range(0, 1280), randf_range(0, 720))
    coin.modulate.a = 0
    coin.play()

    var tween := create_tween()
    tween.tween_property(coin, "modulate", Color(coin.modulate, 1.0), .5)
    tween.tween_property(coin, "modulate", Color(coin.modulate, 0.0), .5)
    tween.play()

    tween.finished.connect(coin.queue_free)

    add_child(coin)