extends Node

signal stat_changed(entity: Node, stat_name: StringName, current_val: float, max_val: float)
signal xp_gained(amount: int, source_level: int)
signal gold_changed(total_gold: int)
signal breakpoint_reached(target_resource: Resource, mutation_choices: Array[Dictionary])
signal dialogue_requested(speaker_name: String, text: String, portrait: Texture2D)
signal dialogue_finished()
signal enemy_killed(enemy_level: int, is_boss: bool, global_pos: Vector2)
signal summon_evolved(summon_id: StringName, new_tier: int)
