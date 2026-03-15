extends Node2D

var castle := Castlevania.new()

@onready var camera_2d: Camera2D = $Camera2D
@onready var mini_cam: Camera2D = %MiniCam
@onready var node_2d: Node2D = %Node2D

var _accum := Vector2.ZERO

func _ready() -> void:
	#for l in castle.generate():
		#add_child.call_deferred(l)
	
	#region.bake_navigation_polygon(false)
	
	node_2d.castle = castle


#func _process(delta: float) -> void:
	#var vec := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized() * 4.0
	#
	#camera_2d.position += vec * delta * 32.0
	##_accum += vec * delta * 4.0
	#
	#camera_2d.position = camera_2d.position.snappedf(1.0)
	#mini_cam.position = (camera_2d.position / 8.0).snappedf(1.0)
