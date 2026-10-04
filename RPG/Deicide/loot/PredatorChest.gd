class_name PredatorChest
extends Node2D

@export var base_free_stats: int = 3

func open_chest(player_level: int, boss_level: int) -> Dictionary:
	# Escalado Inverso (Reverse Scaling) aplicado al loot
	var gap_multiplier: float = Formulas.calculate_reverse_scale(player_level, boss_level)
	
	# Calcular recompensas mitigando el castigo de tener a tu MC anclado a Lvl 1
	var final_free_stats: int = int(float(base_free_stats) * gap_multiplier)
	var rarity_boost_multiplier: float = gap_multiplier
	
	return {
		"free_stats": final_free_stats,
		"rarity_boost": rarity_boost_multiplier
	}
