class_name Projectile
extends HitboxComponent

@export var speed: float = 450.0
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.ZERO
var _life_timer: float = 0.0

func _ready() -> void:
	# Llama al _ready() de HitboxComponent para conectar area_entered
	super._ready()
	hit_landed.connect(_on_hit_landed)

func fire(dir: Vector2, payload: Dictionary) -> void:
	direction = dir.normalized()
	damage_payload = payload
	
	# Orienta la colisión y el sprite hacia la dirección de vuelo
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	# Movimiento rectilíneo uniforme
	global_position += direction * speed * delta
	
	# Control del tiempo de vida
	_life_timer += delta
	if _life_timer >= lifetime:
		queue_free()

func _on_hit_landed() -> void:
	# Autodestrucción al detonar el HitboxComponent
	queue_free()
