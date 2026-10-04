class_name HitboxComponent
extends Area2D

signal hit_landed()

var damage_payload: Dictionary = {
	"base_attack": 0.0,
	"true_damage": 0.0,
	"ignore_defense": false,
	"crit_mult": 1.5,
	"is_crit": false
}

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		area.take_hit(damage_payload)
		hit_landed.emit()
