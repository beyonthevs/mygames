class_name BaseSummon
extends CharacterBody2D

enum State {
	IDLE,
	ORBITING_REAR,
	ATTACKING,
	DEVOURING
}

@export var stats: StatComponent
@export var summon_id: StringName = &"base_summon"

var current_state: State = State.IDLE
var target_enemy: Node2D
var target_corpse: Node2D
var current_tier: int = 1
var move_speed: float = 250.0
var attack_range: float = 60.0

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 1000.0 * delta)
		State.ORBITING_REAR:
			_process_orbiting_rear(delta)
		State.ATTACKING:
			_process_attacking(delta)
		State.DEVOURING:
			_process_devouring(delta)
			
	move_and_slide()

func _process_orbiting_rear(delta: float) -> void:
	if not is_instance_valid(target_enemy):
		current_state = State.IDLE
		return
		
	# Recuperar el vector frontal del enemigo
	var enemy_facing: Vector2 = Vector2.RIGHT
	if target_enemy.has_method("get_facing_direction"):
		enemy_facing = target_enemy.get_facing_direction().normalized()
	elif "facing_direction" in target_enemy:
		enemy_facing = target_enemy.get("facing_direction").normalized()
		
	# Cálculo vectorial para el flanqueo (anti-facing vector)
	var anti_facing_vector: Vector2 = -enemy_facing
	var back_offset: float = 75.0
	
	# Computamos la posición absoluta a espaldas del enemigo
	var rear_position: Vector2 = target_enemy.global_position + (anti_facing_vector * back_offset)
	
	var dir_to_rear: Vector2 = global_position.direction_to(rear_position)
	var dist_to_rear: float = global_position.distance_to(rear_position)
	
	if dist_to_rear > 15.0:
		velocity = velocity.move_toward(dir_to_rear * move_speed, 1200.0 * delta)
	else:
		velocity = Vector2.ZERO
		current_state = State.ATTACKING

func _process_attacking(_delta: float) -> void:
	if not is_instance_valid(target_enemy):
		current_state = State.IDLE
		return
		
	# Validar que el enemigo no se haya escapado del rango crítico
	if global_position.distance_to(target_enemy.global_position) > attack_range * 1.5:
		current_state = State.ORBITING_REAR
		return
		
	_execute_flank_attack()
	# Volver a IDLE forzando el reinicio del ciclo (un sistema real usaría un Timer de cooldown aquí)
	current_state = State.IDLE 

func _execute_flank_attack() -> void:
	if not is_instance_valid(target_enemy) or not is_instance_valid(stats):
		return
		
	# Multiplicador por daño en punto ciego
	var base_damage: float = stats.attack_power
	var final_damage: float = base_damage * 1.5 
	
	if target_enemy.has_method("take_damage"):
		target_enemy.call("take_damage", final_damage)

func _process_devouring(delta: float) -> void:
	if not is_instance_valid(target_corpse):
		current_state = State.IDLE
		return
		
	var dir_to_corpse: Vector2 = global_position.direction_to(target_corpse.global_position)
	var dist_to_corpse: float = global_position.distance_to(target_corpse.global_position)
	
	if dist_to_corpse > 20.0:
		velocity = velocity.move_toward(dir_to_corpse * move_speed, 1200.0 * delta)
	else:
		velocity = Vector2.ZERO
		if target_corpse.has_method("devour"):
			target_corpse.call("devour")
		target_corpse = null
		current_state = State.IDLE

func evolve(new_tier_resource: Resource) -> void:
	current_tier += 1
	if is_instance_valid(stats) and new_tier_resource:
		# Extraer esteroides del recurso de manera agnóstica
		if "bonus_strength" in new_tier_resource:
			stats.base_strength += new_tier_resource.get("bonus_strength") as float
		if "bonus_agility" in new_tier_resource:
			stats.base_agility += new_tier_resource.get("bonus_agility") as float
		stats.recalculate()
		
	# Aquí podría insertarse la lógica para intercambiar el Sprite o la Máscara
