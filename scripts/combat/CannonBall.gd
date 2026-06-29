extends Area3D

@export var default_speed: float = 30.0
@export var default_damage: int = 25
@export var lifetime: float = 3.0

var _velocity: Vector3 = Vector3.ZERO
var _damage: int = 0
var _source: Node
var _age: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	if _damage <= 0:
		_damage = default_damage
	if _velocity.length_squared() <= 0.0:
		_velocity = -global_transform.basis.z * default_speed


func _physics_process(delta: float) -> void:
	global_position += _velocity * delta
	_age += delta

	if _age >= lifetime:
		queue_free()


func launch(direction: Vector3, source: Node, speed: float, damage: int) -> void:
	_source = source
	_damage = damage
	_velocity = direction.normalized() * speed


func _on_body_entered(body: Node) -> void:
	if body == _source:
		return

	_apply_hit(body)


func _on_area_entered(area: Area3D) -> void:
	if area == _source:
		return

	var target := area.get_parent()
	if target != null and target != _source:
		_apply_hit(target)


func _apply_hit(target: Node) -> void:
	if _is_friendly_target(target):
		return

	if target.has_method("take_damage"):
		target.take_damage(_damage)
		queue_free()


func _is_friendly_target(target: Node) -> bool:
	if target == null or _source == null or not is_instance_valid(_source):
		return false

	var source_is_fleet := _source.is_in_group("player") or _source.is_in_group("ally_ships")
	if not source_is_fleet:
		return false

	return target.is_in_group("player") or target.is_in_group("ally_ships")
