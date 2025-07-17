extends CharacterBody3D

signal hit

@export var speed := 14
@export var fall_acceleration := 75
@export var jump_impulse := 20
@export var bounce_impulse := 16
@export var bounding_path: Path3D

var bounding_size := Vector3.ZERO

var target_velocity := Vector3.ZERO

func _ready() -> void:
	if bounding_path == null:
		return
	var curve := bounding_path.curve
	var aabb := AABB()
	
	for index in range(curve.point_count):
		aabb = aabb.expand(curve.get_point_position(index))
	
	bounding_size = aabb.size

func _physics_process(delta: float) -> void:
	var direction := Vector3.ZERO
	
	if (Input.is_anything_pressed()):
		#Input.is_action_pressed("move_right") ||
		#Input.is_action_pressed("move_left") ||
		#Input.is_action_pressed("move_forward") ||
		#Input.is_action_pressed("move_back")
	#):
		direction = Vector3(Input.get_axis("move_left","move_right"), 0, Input.get_axis("move_forward", "move_back")).normalized()
	
	#if Input.is_action_pressed("move_right"):
		#direction.x += 1
	#if Input.is_action_pressed("move_left"):
		#direction.x -= 1
	#if Input.is_action_pressed("move_back"):
		#direction.z += 1
	#if Input.is_action_pressed("move_forward"):
		#direction.z -= 1
		#Input.get_action_strength("move_back")
	
	if Input.is_action_just_pressed("jump"):
		$%JumpBufferTimer.start()
	
	if direction != Vector3.ZERO:
		#direction = direction.normalized()
		$%Pivot.rotation.y = lerp_angle($%Pivot.rotation.y, atan2(-direction.x, -direction.z), 20*delta)
		$%AnimationPlayer.speed_scale = 4
		#$Pivot.basis = Basis.looking_at(direction)
	else:
		$%AnimationPlayer.speed_scale = 1
		
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	elif not $%JumpBufferTimer.is_stopped():
		$%JumpBufferTimer.stop()
		target_velocity.y = jump_impulse
	
	for index in range(get_slide_collision_count()):
		var collision := get_slide_collision(index)
		
		if collision.get_collider() == null || collision.get_collider() is not Node:
			continue
		
		var collider: Node = collision.get_collider()
		if collider.is_in_group("mob"):
			var mob: Mob = collider
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				mob.squash()
				target_velocity.y = bounce_impulse
				break
	
	$%Pivot.rotation.x = PI/6 * velocity.y / jump_impulse
	
	velocity = target_velocity
	
	position.x = clamp(position.x, -bounding_size.x/2, bounding_size.x/2)
	position.z = clamp(position.z, -bounding_size.z/2, bounding_size.z/2)
	
	move_and_slide()

func _on_mob_detector_body_entered(_body: Node3D) -> void:
	die()

func die() -> void:
	hit.emit()
	queue_free()
