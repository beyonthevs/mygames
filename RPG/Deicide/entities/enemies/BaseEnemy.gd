class_name BaseEnemy
extends CharacterBody2D

@export var stats: StatComponent
@export var hurtbox: HurtboxComponent
@export var chest_scene: PackedScene

@export var enemy_name: String = "Lobo Menor"
@export var enemy_level: int = 5
@export var is_boss: bool = false
@export var base_xp_reward: int = 50
@export var chase_speed: float = 120.0

var target_player: Node2D = null

func _ready() -> void:
	# Inyección de dependencia garantizada
	if is_instance_valid(hurtbox) and hurtbox.stat_component == null:
		hurtbox.stat_component = stats
		
	if is_instance_valid(stats):
		# Conexión directa a entity_died. 
		# Nota: Asegúrate de declarar 'signal entity_died' en tu StatComponent.
		if stats.has_signal("entity_died"):
			stats.entity_died.connect(_on_death)
		else:
			# Fallback arquitectónico usando el EventBus que ya programamos
			EventBus.stat_changed.connect(_on_global_stat_changed)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target_player):
		_find_target()
		
	if is_instance_valid(target_player):
		var target_pos: Vector2 = target_player.global_position
		var move_direction: Vector2 = global_position.direction_to(target_pos)
		
		# Rotación angular suave
		var target_angle: float = move_direction.angle()
		rotation = lerp_angle(rotation, target_angle, 8.0 * delta)
		
		velocity = move_direction * chase_speed
		move_and_slide()

func _find_target() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target_player = players[0] as Node2D

func _on_global_stat_changed(entity: Node, stat_name: StringName, current_val: float, _max_val: float) -> void:
	# Monitoreo reactivo en caso de que StatComponent no exponga entity_died
	if entity == stats and stat_name == &"hp" and current_val <= 0.0:
		_on_death()

func _on_death() -> void:
	# Notificamos al sistema global del deceso, escalado y biomasa
	EventBus.enemy_killed.emit(enemy_level, is_boss, global_position)
	
	# Drop estocástico garantizado si es una deidad / hereje
	if is_boss and is_instance_valid(chest_scene):
		var chest: Node = chest_scene.instantiate()
		# Usamos call_deferred para evitar modificar el árbol durante físicas
		get_tree().current_scene.call_deferred("add_child", chest)
		
		var chest_2d: Node2D = chest as Node2D
		if chest_2d:
			# Asignamos la posición de manera segura en el siguiente frame físico
			chest_2d.set_deferred("global_position", global_position)
			
	queue_free()

# Para compatibilidad con los ataques laterales de BaseSummon
func get_facing_direction() -> Vector2:
	return Vector2.RIGHT.rotated(rotation)
