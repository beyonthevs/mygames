class_name BaseEnemy
extends CharacterBody2D

@export var stat_component: StatComponent
@export var hurtbox_component: HurtboxComponent
@export var chest_scene: PackedScene

@export var enemy_name: String = "Lobo Menor"
@export var enemy_level: int = 5
@export var is_boss: bool = false
@export var base_xp_reward: int = 50
@export var chase_speed: float = 120.0

var target_player: Node2D = null

func _ready() -> void:
	if is_instance_valid(hurtbox_component) and hurtbox_component.stat_component == null:
		hurtbox_component.stat_component = stat_component
		
	if is_instance_valid(stat_component):
		if stat_component.has_signal("entity_died"):
			stat_component.entity_died.connect(_on_death)
		else:
			EventBus.stat_changed.connect(_on_global_stat_changed)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target_player):
		_find_target()
		
	if is_instance_valid(target_player):
		var target_pos: Vector2 = target_player.global_position
		var move_direction: Vector2 = global_position.direction_to(target_pos)
		
		var target_angle: float = move_direction.angle()
		rotation = lerp_angle(rotation, target_angle, 8.0 * delta)
		
		velocity = move_direction * chase_speed
		move_and_slide()

func _find_target() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target_player = players[0] as Node2D

func _on_global_stat_changed(entity: Node, stat_name: StringName, current_val: float, _max_val: float) -> void:
	if entity == stat_component and stat_name == &"hp" and current_val <= 0.0:
		_on_death()

func _on_death() -> void:
	EventBus.enemy_killed.emit(enemy_level, is_boss, global_position)
	
	if is_boss and is_instance_valid(chest_scene):
		var chest: Node = chest_scene.instantiate()
		get_tree().current_scene.call_deferred("add_child", chest)
		
		var chest_2d: Node2D = chest as Node2D
		if chest_2d:
			chest_2d.set_deferred("global_position", global_position)
			
	queue_free()

func get_facing_direction() -> Vector2:
	return Vector2.RIGHT.rotated(rotation)
