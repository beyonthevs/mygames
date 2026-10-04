class_name SummonManager
extends Node

@export var max_active_summons: int = 4
@export var base_summon_scene: PackedScene

var active_summons: Array[BaseSummon] = []

func _ready() -> void:
	# Escuchamos el asesinato de enemigos desde el EventBus Global
	EventBus.enemy_killed.connect(_on_enemy_killed)

func spawn_summon(global_pos: Vector2) -> BaseSummon:
	_cleanup_pool()
	
	if active_summons.size() >= max_active_summons or not is_instance_valid(base_summon_scene):
		return null
		
	var inst: BaseSummon = base_summon_scene.instantiate() as BaseSummon
	add_child(inst)
	inst.global_position = global_pos
	active_summons.append(inst)
	
	return inst

func evolve_summons(new_tier_resource: Resource) -> void:
	if not is_instance_valid(new_tier_resource):
		push_error("SummonManager: Recurso de evolución inválido provisto.")
		return
		
	_cleanup_pool()
	
	# Disparamos la evolución para cada ente biológico activo
	for summon in active_summons:
		summon.evolve(new_tier_resource)
		# Emitimos su cambio para el HUD o el Tracker de logros
		EventBus.summon_evolved.emit(summon.summon_id, summon.current_tier)

func _on_enemy_killed(enemy_level: int, is_boss: bool, _global_pos: Vector2) -> void:
	# Si un jefe cae, los súbditos devoran los remanentes cósmicos (Auto-Evolución)
	if is_boss:
		var synthetic_boss_essence: Resource = Resource.new()
		# Ajuste dinámico agnóstico al tier
		synthetic_boss_essence.set("bonus_strength", 15.0 * enemy_level)
		synthetic_boss_essence.set("bonus_agility", 10.0 * enemy_level)
		
		evolve_summons(synthetic_boss_essence)

func _cleanup_pool() -> void:
	# Filtramos instancias destruidas o liberadas (queue_free)
	active_summons = active_summons.filter(func(s: BaseSummon) -> bool: return is_instance_valid(s))
