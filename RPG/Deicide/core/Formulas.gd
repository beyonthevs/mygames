class_name Formulas
extends RefCounted

static func calculate_reverse_scale(player_lvl: int, enemy_lvl: int) -> float:
	if enemy_lvl <= player_lvl:
		return 1.0
	return 1.0 + float(enemy_lvl - player_lvl) * 0.10

static func get_upgrade_cost(base_cost: int, current_tier: int) -> int:
	return int(float(base_cost) * pow(2.0, float(current_tier)))

static func calculate_damage(attack: float, target_defense: float, ignore_defense: bool, crit_mult: float, is_crit: bool, true_damage: float) -> float:
	var final_damage: float = attack
	
	if not ignore_defense:
		# Using a standard damage mitigation formula based on defense
		var mitigation: float = 100.0 / (100.0 + maxf(0.0, target_defense))
		final_damage *= mitigation
		
	if is_crit:
		final_damage *= crit_mult
		
	final_damage += true_damage
	
	return maxf(0.0, final_damage)
