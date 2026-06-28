extends Area3D

@export var speed: float = 13.0
@export var damage: int = 5
@export var lifetime: float = 2.8

var _velocity: Vector3 = Vector3.ZERO
var _source: Node
var _age: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	global_position += _velocity * delta
	_age += delta

	if _age >= lifetime:
		queue_free()


func launch(direction: Vector3, source: Node, projectile_speed: float, hit_damage: int) -> void:
	_source = source
	speed = projectile_speed
	damage = hit_damage
	_velocity = direction.normalized() * speed


func _on_body_entered(body: Node) -> void:
	if body == _source:
		return

	if not body.is_in_group("player") and not body.is_in_group("ally_ships"):
		return

	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
