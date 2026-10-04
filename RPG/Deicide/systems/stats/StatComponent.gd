class_name StatComponent
extends Node

@export var base_strength: float = 10.0
@export var base_agility: float = 10.0
@export var base_constitution: float = 10.0
@export var base_spirit: float = 10.0

var flat_modifiers: Dictionary = {}
var percent_modifiers: Dictionary = {}

var current_hp: float = 0.0
var max_hp: float = 0.0
var current_mp: float = 0.0
var max_mp: float = 0.0
var attack_power: float = 0.0
var defense: float = 0.0

func _ready() -> void:
	recalculate()
	current_hp = max_hp
	current_mp = max_mp
	_emit_core_stats()

func recalculate() -> void:
	var total_strength: float = (base_strength + _get_flat_mod(&"strength")) * _get_percent_mod(&"strength")
	var total_constitution: float = (base_constitution + _get_flat_mod(&"constitution")) * _get_percent_mod(&"constitution")
	var total_spirit: float = (base_spirit + _get_flat_mod(&"spirit")) * _get_percent_mod(&"spirit")
	
	max_hp = total_constitution * 20.0 + _get_flat_mod(&"max_hp")
	max_mp = total_spirit * 20.0 + _get_flat_mod(&"max_mp")
	attack_power = total_strength * 2.5 + _get_flat_mod(&"attack_power")
	defense = total_constitution * 1.0 + _get_flat_mod(&"defense")
	
	current_hp = clampf(current_hp, 0.0, max_hp)
	current_mp = clampf(current_mp, 0.0, max_mp)
	
	_emit_core_stats()

func _get_flat_mod(stat: StringName) -> float:
	return flat_modifiers.get(stat, 0.0)

func _get_percent_mod(stat: StringName) -> float:
	return 1.0 + percent_modifiers.get(stat, 0.0)

func add_flat_modifier(stat: StringName, val: float) -> void:
	flat_modifiers[stat] = _get_flat_mod(stat) + val
	recalculate()

func take_damage(amount: float) -> void:
	if amount <= 0.0:
		return
	current_hp = maxf(0.0, current_hp - amount)
	EventBus.stat_changed.emit(self, &"hp", current_hp, max_hp)

func heal(amount: float) -> void:
	if amount <= 0.0:
		return
	current_hp = minf(max_hp, current_hp + amount)
	EventBus.stat_changed.emit(self, &"hp", current_hp, max_hp)

func _emit_core_stats() -> void:
	EventBus.stat_changed.emit(self, &"hp", current_hp, max_hp)
	EventBus.stat_changed.emit(self, &"mp", current_mp, max_mp)
