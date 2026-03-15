extends Area2D

var speed := 6.0
var direction: Vector2

var left: Vector2
var accum := 0.0

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var point_light_2d_2: PointLight2D = $PointLight2D2
@onready var gpu_particles_2d_2: GPUParticles2D = $GPUParticles2D2

var type := 0

func setup(player: Node2D, mouse_pos: Vector2):
	direction = player.position.direction_to(mouse_pos)
	global_position = player.position
	
	direction = direction.rotated(randf_range(-1.0, 1.0) * 0.1)
	
	var angle := Vector2.UP.angle_to(direction)
	left = Vector2.RIGHT.rotated(angle)
	
	type = randi_range(0, 1)

func _physics_process(delta: float) -> void:
	sprite_2d.rotate(delta * speed)
	point_light_2d.rotate(delta * -speed)
	point_light_2d_2.rotate(delta * speed / 2.0)
	
	accum += delta * 2.0
	
	var base := direction * speed * 32.0
	var sway := left * sin(accum * speed) * accum * 256.0
	
	match type:
		0: position += base * delta
		1: position += (base + sway) * delta


func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		gpu_particles_2d.emitting = false
		sprite_2d.visible = false
		point_light_2d.visible = false
		point_light_2d_2.visible = false
		collision_shape_2d.set_deferred("disabled", true)
		gpu_particles_2d_2.restart()
	if body is CharacterBody2D:
		if body.get_collision_layer_value(5):
			gpu_particles_2d.emitting = false
			sprite_2d.visible = false
			point_light_2d.visible = false
			point_light_2d_2.visible = false
			collision_shape_2d.set_deferred("disabled", true)
			gpu_particles_2d_2.restart()
			body.damage(global_position.direction_to(body.global_position), 2)


func _on_gpu_particles_2d_finished() -> void:
	queue_free()
	pass # Replace with function body.
