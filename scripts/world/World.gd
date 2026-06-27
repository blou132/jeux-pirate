extends Node3D

@onready var player: Node = $PlayerBoat
@onready var hud: CanvasLayer = $HUD


func _ready() -> void:
	if hud.has_method("set_player"):
		hud.set_player(player)
