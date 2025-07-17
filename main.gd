extends Node

@export var mob_scene: PackedScene


func _ready() -> void:
	$%Retry.hide()

func _on_mob_timer_timeout() -> void:
	var mob: Mob = mob_scene.instantiate()
	
	var mob_spawn_location: PathFollow3D = $%SpawnLocation
	mob_spawn_location.progress_ratio = randf()
	
	var player_position: Vector3 = $%Player.position
	
	mob.initialize(mob_spawn_location.position, player_position)
	
	add_child(mob)
	
	mob.squashed.connect($%ScoreLabel._on_mob_squashed.bind())
	


func _on_player_hit() -> void:
	$%MobTimer.stop()
	$%Retry.show()
	$%RetryLayerAnimation.play("Show")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and $%Retry.visible:
		get_tree().reload_current_scene()
