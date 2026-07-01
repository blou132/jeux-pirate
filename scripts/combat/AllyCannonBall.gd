extends Area3D

@export var speed: float = 16.0
@export var damage: int = 8
@export var lifetime: float = 2.6

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
	if not body.is_in_group("enemy_ships") and not body.is_in_group("marine_creatures"):
		return
	if body.has_method("is_destroyed") and body.is_destroyed():
		return

	if body.has_method("take_damage"):
		body.take_damage(damage, _source)
		if not body.has_method("is_destroyed") or not body.is_destroyed():
			_show_hit_feedback(damage)
		queue_free()


func _show_hit_feedback(hit_damage: int) -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("show_temporary_context_message"):
		hud.show_temporary_context_message("Allié a touché : -%d PV" % hit_damage, 0.9)
