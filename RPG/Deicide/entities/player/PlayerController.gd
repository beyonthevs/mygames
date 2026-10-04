class_name PlayerController
extends CharacterBody2D

@export var stat_component: StatComponent
@export var projectile_scene: PackedScene = preload("res://scenes/Projectile.tscn")
@export var base_speed: float = 220.0

func _physics_process(_delta: float) -> void:
	var input_dir: Vector2 = Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
		input_dir.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
		input_dir.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		input_dir.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		input_dir.x += 1.0
	velocity = input_dir.normalized() * base_speed
	move_and_slide()
	look_at(get_global_mouse_position())

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or (event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_SPACE):
		shoot()

func shoot() -> void:
	if projectile_scene == null:
		projectile_scene = load("res://scenes/Projectile.tscn")
		
	var proj = projectile_scene.instantiate()
	
	var spawn_pos: Vector2 = global_position
	if has_node("Muzzle"):
		spawn_pos = get_node("Muzzle").global_position
		
	var shoot_dir: Vector2 = (get_global_mouse_position() - spawn_pos).normalized()
	if shoot_dir == Vector2.ZERO:
		shoot_dir = Vector2.RIGHT
		
	get_tree().current_scene.add_child(proj)
	proj.global_position = spawn_pos
	
	if "direction" in proj:
		proj.direction = shoot_dir
		
	if "damage_payload" in proj:
		var atk: float = stat_component.attack_power if stat_component else 25.0
		proj.damage_payload = {
			"base_attack": atk,
			"true_damage": 0.0,
			"ignore_defense": false,
			"crit_mult": 1.5,
			"is_crit": false
		}
		
	print("[Player] Proyectil instanciado hacia: ", shoot_dir)
