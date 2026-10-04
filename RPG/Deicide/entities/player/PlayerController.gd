class_name PlayerController
extends CharacterBody2D

@export var stats: StatComponent
@export var muzzle: Marker2D
@export var projectile_scene: PackedScene
@export var base_speed: float = 200.0

func _physics_process(_delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var agility_multiplier: float = 1.0
	if is_instance_valid(stats):
		# Uso de get_stat si existe, de lo contrario un fallback normalizado con base_agility
		if stats.has_method("get_stat"):
			agility_multiplier = stats.call("get_stat", "agility", 1.0) as float
		else:
			agility_multiplier = maxf(0.5, stats.base_agility / 10.0)
			
	velocity = input_vector * (base_speed * agility_multiplier)
	move_and_slide()
	
	# Apunta el pivote del jugador hacia el ratón
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
	
	# Verificamos si es un tipo Projectile válido
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
	
	if is_instance_valid(stats):
		payload["base_attack"] = stats.attack_power
		# Aplicación aleatoria de crítico (Ej. 15% chance base)
		payload["is_crit"] = randf() < 0.15
		
	projectile.fire(fire_direction, payload)
