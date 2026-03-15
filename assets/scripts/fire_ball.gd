extends Skill
@onready var fireball: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer

var hit = false
var speed = 170
var random_angle: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	random_angle = deg_to_rad(randf_range(-60, 60))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hit == false:
		launch(delta)

func launch(delta):
	var dir = direction.rotated(random_angle)
	
	fireball.rotation = dir.angle() + PI
	
	animation_player.play("fireball_move")
	fireball.position += dir * speed * delta

func setup(player, mouse_pos):
	direction = (mouse_pos - player.position).normalized()
	global_position = player.position

func _on_area_2d_area_entered(area: Area2D) -> void:
	hit = true
	print(area)
	animation_player.play("fireball_blow")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fireball_blow":
		queue_free()
