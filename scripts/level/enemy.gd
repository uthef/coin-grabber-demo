# узел, отвечающий за поведение врага
class_name Enemy extends CharacterBody2D

signal target_caught()

var speed := 150.0

@export
var target_desired_distance := 3.0

@export 
var movement_detection_threshold = Vector2(speed / 2. , speed / 2.)

@onready
var nav_agent: NavigationAgent2D = $NavigationAgent2D

@onready
var sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready 
var player: Player = null

var attacking: bool = false
var chasing: bool = false

var activation_delay := 3.

func _ready() -> void:
	target_desired_distance = speed / 150.0 * 3.0

	for node in get_tree().get_nodes_in_group("player"):
		player = node
		break

	set_physics_process(false)
	sprite.play()


func _physics_process(_delta: float) -> void:
	# начать преследованиие, когда игрок поблизости
	chasing = player.position.distance_to(position) < 300
	$ExclamationMark.visible = chasing

	if chasing:
		if not $ExclamationMark.is_playing():
			$ExclamationMark.play()
		
		nav_agent.target_position = player.position	

	# смена анимаций и разворота спрайта
	if get_real_velocity().abs().x > speed / 2 or get_real_velocity().abs().y > speed / 2:
		sprite.flip_h = velocity.x < 0

		if not attacking: 
			sprite.animation = "walk_left"
	elif not attacking:
		sprite.animation = "idle_down"

	# атака
	if player.position.distance_to(position) < 40:
		sprite.flip_h = player.position.x < position.x
		sprite.animation = "attack"
		attacking = true
	
	# перемещение

	if position.distance_to(nav_agent.get_final_position()) > target_desired_distance:
		velocity = position.direction_to(nav_agent.get_next_path_position()).normalized() * speed
	else:
		velocity = Vector2.ZERO
	

	var has_collisions := move_and_slide()

	# обнаружение коллизии
	if has_collisions:
		for i in get_slide_collision_count():
			var collision := get_slide_collision(i)
			var collider := collision.get_collider()

			if collider == null:
				continue

			if collider == player and player.coin_count < player.max_coin_count:
				# при столкновении с игроком
				emit_signal("target_caught")
				set_physics_process(false)
				sprite.flip_h = player.position.x < position.x
				player.freeze()
				
				break


func _on_level_navigation_map_available(map_id: RID) -> void:
	# задержка активации врага
	await get_tree().create_timer(activation_delay).timeout

	nav_agent.set_navigation_map(map_id)
	set_physics_process(true)
	set_target_to_random()


func _on_animated_sprite_2d_animation_finished() -> void:
	# после окончании анимации атаки снова запускаем анимацию
	# и возвращаем врага в состояние idle
	if sprite.animation == "attack":
		sprite.animation = "idle_down"
		sprite.play()
		attacking = false


func set_target_to_random() -> void:
	nav_agent.target_position = Vector2(
		randf_range(0, player.movement_limits.end.x), 
		randf_range(0, player.movement_limits.end.y)
	)


func _on_navigation_agent_2d_navigation_finished() -> void:
	if not chasing:
		await get_tree().create_timer(1).timeout
		set_target_to_random()
