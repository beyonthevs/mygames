class_name Projectile
extends HitboxComponent

@export var speed: float = 550.0
@export var lifetime: float = 2.5

var direction: Vector2 = Vector2.ZERO
var _timer: float = 0.0

func _ready() -> void:
	collision_layer = 4
	collision_mask = 2
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	_timer += delta
	if _timer >= lifetime:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		area.take_hit(damage_payload)
		queue_free()
