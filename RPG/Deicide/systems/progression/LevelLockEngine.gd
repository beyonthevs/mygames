class_name LevelLockEngine
extends Node

var player_level: int = 1
var experience_pool: int = 0
var gold_balance: int = 0

func process_enemy_defeat(enemy_level: int, base_xp: int) -> void:
	var xp_multiplier: float = Formulas.calculate_reverse_scale(player_level, enemy_level)
	var final_xp: int = int(float(base_xp) * xp_multiplier)
	
	experience_pool += final_xp
	EventBus.xp_gained.emit(final_xp, enemy_level)

func spend_xp(cost: int) -> bool:
	if can_afford(cost):
		experience_pool -= cost
		return true
	return false

func can_afford(cost: int) -> bool:
	return experience_pool >= cost
