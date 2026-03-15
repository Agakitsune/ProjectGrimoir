extends Area2D

var speed := 6.0
var direction: Vector2

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sprite_2d_2: Sprite2D = $Sprite2D2

func _physics_process(delta: float) -> void:
	sprite_2d.rotate(delta * speed)
	sprite_2d_2.rotate(delta * -speed)

	position += direction * speed * 32.0 * delta


func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		queue_free()
	if body is CharacterBody2D:
		if body.get_collision_layer_value(3):
			queue_free()
			# damage player
