class_name InfusionSystem
extends Node

func attempt_infuse(target_item: Resource, engine: LevelLockEngine) -> bool:
	# Validar que el recurso posea los parámetros mínimos del contrato de equipo
	if not target_item or not ("upgrade_level" in target_item) or not ("affixes" in target_item):
		push_error("InfusionSystem: El recurso no es válido o carece de los atributos requeridos.")
		return false
		
	var current_tier: int = target_item.get("upgrade_level") as int
	var base_cost: int = 100
	
	if "base_cost" in target_item:
		base_cost = target_item.get("base_cost") as int
		
	var cost: int = Formulas.get_upgrade_cost(base_cost, current_tier)
	
	# Transacción atómica
	if engine.spend_xp(cost):
		var new_tier: int = current_tier + 1
		target_item.set("upgrade_level", new_tier)
		
		# Punto de inflexión estocástico cada 4 niveles
		if new_tier % 4 == 0:
			_generate_and_emit_breakpoint(target_item)
			
		return true
		
	return false

func _generate_and_emit_breakpoint(target_item: Resource) -> void:
	var mutation_pool: Array[Dictionary] = [
		{
			"id": "ignore_defense",
			"title": "Perforación Absoluta",
			"description": "Tus ataques ignoran el 100% de la armadura enemiga.",
			"apply_callable": func() -> void:
				var affixes: Dictionary = target_item.get("affixes")
				affixes["ignore_defense"] = true
		},
		{
			"id": "bonus_true_damage",
			"title": "Eco Etéreo",
			"description": "Suma 25 puntos de daño verdadero inmitigable.",
			"apply_callable": func() -> void:
				var affixes: Dictionary = target_item.get("affixes")
				var current_td: float = affixes.get("bonus_true_damage", 0.0) as float
				affixes["bonus_true_damage"] = current_td + 25.0
		},
		{
			"id": "projectile_split",
			"title": "Fragmentación",
			"description": "Los proyectiles se fracturan en 2 vectores adicionales.",
			"apply_callable": func() -> void:
				var affixes: Dictionary = target_item.get("affixes")
				var current_split: int = affixes.get("projectile_split", 0) as int
				affixes["projectile_split"] = current_split + 2
		},
		{
			"id": "reroll_token",
			"title": "Misericordia del Destino",
			"description": "Consigue 1 Token para hacer Reroll en futuros Breakpoints.",
			"apply_callable": func() -> void:
				var affixes: Dictionary = target_item.get("affixes")
				var current_tokens: int = affixes.get("reroll_tokens", 0) as int
				affixes["reroll_tokens"] = current_tokens + 1
		}
	]
	
	# Algoritmo de bifurcación estocástica pura
	mutation_pool.shuffle()
	var selected_mutations: Array[Dictionary] = []
	for i in range(3):
		selected_mutations.append(mutation_pool[i])
		
	EventBus.breakpoint_reached.emit(target_item, selected_mutations)
