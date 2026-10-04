class_name PlayerController
extends CharacterBody2D

@export var stat_component: StatComponent
@export var muzzle: Marker2D
@export var projectile_scene: PackedScene
@export var base_speed: float = 200.0

func _physics_process(_delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var agility_multiplier: float = 1.0
	if is_instance_valid(stat_component):
		if stat_component.has_method("get_stat"):
			agility_multiplier = stat_component.call("get_stat", "agility", 1.0) as float
		else:
			agility_multiplier = maxf(0.5, stat_component.base_agility / 10.0)
			
	velocity = input_vector * (base_speed * agility_multiplier)
	move_and_slide()
	
	look_at(get_global_mouse_position())

func _unhandled_input(event: InputEvent) -> void:
	var is_shooting: bool = event.is_action_pressed("ui_accept")
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_shooting = true
			
	if is_shooting:
		shoot()

func shoot() -> void:
	if not is_instance_valid(projectile_scene) or not is_instance_valid(muzzle):
		return
		
	var projectile_node: Node = projectile_scene.instantiate()
	var projectile: Projectile = projectile_node as Projectile
	if not projectile:
		projectile_node.queue_free()
		return
		
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = muzzle.global_position
	
	var target_pos: Vector2 = get_global_mouse_position()
	var fire_direction: Vector2 = muzzle.global_position.direction_to(target_pos)
	
	var payload: Dictionary = {
		"base_attack": 5.0,
		"true_damage": 0.0,
		"ignore_defense": false,
		"crit_mult": 1.5,
		"is_crit": false
	}
	
	if is_instance_valid(stat_component):
		payload["base_attack"] = stat_component.attack_power
		payload["is_crit"] = randf() < 0.15
		
	projectile.fire(fire_direction, payload)
