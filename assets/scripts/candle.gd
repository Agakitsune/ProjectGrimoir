extends Node2D

@onready var point_light_2d_2: PointLight2D = $PointLight2D2
@onready var point_light_2d_4: PointLight2D = $PointLight2D4
@onready var point_light_2d: PointLight2D = $PointLight2D

func _ready() -> void:
	point_light_2d.rotation = randi_range(0, 2.4)
	point_light_2d_2.rotation = randi_range(0, 2.4)
	point_light_2d_4.rotation = randi_range(0, 2.4)


func _process(delta: float) -> void:
	point_light_2d.rotate(delta * 0.25)
	point_light_2d_2.rotate(delta * -0.1)
	point_light_2d_4.rotate(delta * 0.05)
