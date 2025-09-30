# узел отвечает за поведение игрового персонажа
class_name Player
extends CharacterBody2D

# сигнал об изменении кол-ва собранных монет
signal coin_count_changed(coins: int, max_coins: int)


var speed := 180.0

@onready
var sprite: AnimatedSprite2D = $AnimatedSprite

var coin_count: int = 0
var max_coin_count: int = 8

var movement_limits: Rect2 = Rect2(0, 0, 0, 0) :
	set(value):
		$Camera2D.limit_left = value.position.x
		$Camera2D.limit_top = value.position.y
		$Camera2D.limit_right = value.end.x
		$Camera2D.limit_bottom = value.end.y

		movement_limits = value
	get:
		return movement_limits


func _ready() -> void:
	sprite.play()


class Movement:
	var animation := "idle_down"
	var direction := Vector2.ZERO


# получение пользовательского ввода
func get_movement() -> Movement:
	var movement := Movement.new()
	
	if Input.is_action_pressed("move_left"):
		movement.animation = "run_left"
		movement.direction += Vector2.LEFT
	elif Input.is_action_pressed("move_right"):
		movement.animation = "run_right"
		movement.direction += Vector2.RIGHT
	if Input.is_action_pressed("move_up"):
		movement.animation = "run_up"
		movement.direction += Vector2.UP
	elif Input.is_action_pressed("move_down"):
		movement.animation = "run_down"
		movement.direction += Vector2.DOWN
	
	return movement


func _physics_process(_delta: float) -> void:
	var movement := get_movement()

	if movement.direction == Vector2.ZERO:
		sprite.animation = sprite.animation.replace("run", "idle")
	else:
		sprite.animation = movement.animation 

	velocity = constrain_movement(movement).direction.normalized() * speed
	move_and_slide()


func constrain_movement(movement: Movement) -> Movement:
	# ограничение перемещения за пределы карты
	
	if movement_limits.size != Vector2.ZERO:
		var next_position := position + movement.direction

		if next_position.x > movement_limits.end.x:
			movement.direction.x = min(0, movement.direction.x)
		elif next_position.x < movement_limits.position.x:
			movement.direction.x = max(0, movement.direction.x)

		if next_position.y > movement_limits.end.y:
			movement.direction.y = min(0, movement.direction.y)
		elif next_position.y < movement_limits.position.y:
			movement.direction.y = max(0, movement.direction.y)
	
	return movement


# добавить монеты в счётчик
func collect_coin(amount: int = 1) -> void:
	coin_count += amount
	emit_signal("coin_count_changed", coin_count, max_coin_count)


func freeze() -> void:
	set_physics_process(false)
