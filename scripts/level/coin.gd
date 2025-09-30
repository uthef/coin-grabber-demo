# узел отвечает за поведение монет
extends Area2D


func _ready() -> void:
    $AnimatedSprite.play()


func _on_body_entered(body: Node2D) -> void:
    # отложенное отключение обнаружения проникновений, 
    # чтобы сигнал body_entered никогда не срабатывал более одного раза
    # при повторном попадании игрока в область коллизии
    set_deferred("monitoring", false)

    remove_from_group("coins")
    disappear(.2, false)

    # оповещение игрока о собранной монете
    if body is Player:
        body.collect_coin()
    
    $Sound.play()


func disappear(duration: float = .2, free: bool = true) -> void:
    # плавное исчезновение
    var tween := create_tween()
    tween.tween_property(self, "modulate", Color(modulate, 0), duration)
    
    if free:
        tween.finished.connect(queue_free)


func _on_sound_finished():
    queue_free()