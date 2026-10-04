class_name HurtboxComponent
extends Area2D

@export var stat_component: StatComponent

func take_hit(payload: Dictionary) -> void:
	if not is_instance_valid(stat_component):
		push_error("HurtboxComponent: No se ha asignado un StatComponent válido.")
		return
		
	var target_defense: float = stat_component.defense
	
	var base_attack: float = payload.get("base_attack", 0.0) as float
	var true_damage: float = payload.get("true_damage", 0.0) as float
	var ignore_defense: bool = payload.get("ignore_defense", false) as bool
	var crit_mult: float = payload.get("crit_mult", 1.5) as float
	var is_crit: bool = payload.get("is_crit", false) as bool
	
	var final_damage: float = Formulas.calculate_damage(
		base_attack,
		target_defense,
		ignore_defense,
		crit_mult,
		is_crit,
		true_damage
	)
	
	stat_component.take_damage(final_damage)
