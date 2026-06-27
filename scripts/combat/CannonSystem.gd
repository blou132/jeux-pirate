extends Node3D

@export var cannon_ball_scene: PackedScene = preload("res://scenes/projectiles/CannonBall.tscn")
@export var cooldown: float = 0.8
@export var shot_speed: float = 30.0
@export var damage: int = 25

@onready var port_muzzle: Marker3D = $PortMuzzle
@onready var starboard_muzzle: Marker3D = $StarboardMuzzle

var _port_cooldown: float = 0.0
var _starboard_cooldown: float = 0.0


func _process(delta: float) -> void:
	_port_cooldown = maxf(0.0, _port_cooldown - delta)
	_starboard_cooldown = maxf(0.0, _starboard_cooldown - delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			fire_port()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			fire_starboard()


func fire_port() -> void:
	if _port_cooldown > 0.0:
		return

	_fire(port_muzzle, -global_transform.basis.x)
	_port_cooldown = cooldown


func fire_starboard() -> void:
	if _starboard_cooldown > 0.0:
		return

	_fire(starboard_muzzle, global_transform.basis.x)
	_starboard_cooldown = cooldown


func _fire(muzzle: Marker3D, direction: Vector3) -> void:
	if cannon_ball_scene == null:
		return

	var cannon_ball := cannon_ball_scene.instantiate()
	if not cannon_ball is Node3D:
		return

	var source := get_parent()
	var ball_node := cannon_ball as Node3D
	ball_node.global_position = muzzle.global_position

	if cannon_ball.has_method("launch"):
		cannon_ball.launch(direction, source, shot_speed, damage)

	var parent := get_tree().current_scene
	if parent == null:
		parent = get_tree().root
	parent.add_child(cannon_ball)
