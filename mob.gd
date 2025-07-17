class_name Mob

extends CharacterBody3D

signal squashed

@export var min_speed: int = 10
@export var max_speed: int = 18

func _physics_process(_delta: float) -> void:
	move_and_slide()


func initialize(start_position: Vector3, player_position: Vector3) -> void:
	var target = Vector3(player_position.x, start_position.y, player_position.z)
	look_at_from_position(start_position, target, Vector3.UP)
	rotate_y(randf_range(-PI/4, PI/4))
	
	var random_speed = randi_range(min_speed, max_speed)
	velocity = Vector3.FORWARD * random_speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	
	$%AnimationPlayer.speed_scale = random_speed / float(min_speed)

func squash() -> void:
	squashed.emit()
	queue_free()


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()
