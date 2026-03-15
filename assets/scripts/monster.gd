extends CharacterBody2D

const BULLET := preload("uid://dxva2qkax7p66")

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var wander: Timer = $Wander
@onready var shoot: Timer = $Shoot
@onready var stun: Timer = $Stun

@export var goal: Node2D
@export var max_chase_distance := 400.0
@export var min_chase_distance := 100.0
@export var health := 8

var _stun: Vector2

enum State {
	Idle,
	Wander,
	Chase,
	Stun
}

var state := State.Idle


func damage(from: Vector2, x: int):
	health -= x
	
	state = State.Stun
	
	if health <= 0:
		collision_shape_2d.set_deferred("disabled", true)
		stun.start(1.0)
	else:
		stun.start(0.5)
	
	_stun = from


func _ready() -> void:
	wander.start(randf_range(2.0, 3.0))


func _physics_process(delta: float) -> void:
	if health <= 0:
		modulate.v = move_toward(modulate.v, .4, delta)
		if modulate.v <= 0.41:
			set_physics_process(false)
	
	match state:
		State.Idle: idle_process(delta)
		State.Wander: wander_process(delta)
		State.Chase: chase_process(delta)
		State.Stun: stun_process(delta)


func idle_process(delta: float) -> void:
	if global_position.distance_to(goal.global_position) < max_chase_distance:
		state = State.Chase
		wander.stop()
		shoot.start()
		return


func wander_process(delta: float) -> void:
	if global_position.distance_to(goal.global_position) < max_chase_distance:
		state = State.Chase
		wander.stop()
		shoot.start()
		return
	
	if NavigationServer2D.map_get_iteration_id(agent.get_navigation_map()) == 0:
		return
	if agent.is_navigation_finished():
		state = State.Idle
		wander.start(randf_range(2.0, 3.0))
		return
	
	var next := agent.get_next_path_position()
	
	velocity = global_position.direction_to(next) * 64.0
	move_and_slide()


func chase_process(delta: float) -> void:
	if NavigationServer2D.map_get_iteration_id(agent.get_navigation_map()) == 0:
		return
	if agent.is_navigation_finished():
		agent.target_position = goal.global_position
		return
	
	if global_position.distance_to(goal.global_position) >= max_chase_distance:
		state = State.Idle
		wander.start(randf_range(2.0, 3.0))
		shoot.stop()
		return
	if global_position.distance_to(goal.global_position) < min_chase_distance:
		return
	
	agent.target_position = goal.global_position
	
	var next := agent.get_next_path_position()
	
	velocity = global_position.direction_to(next) * 64.0
	move_and_slide()


func stun_process(delta: float) -> void:
	_stun = _stun.move_toward(Vector2.ZERO, delta * 2.0)
	velocity = _stun * 64.0
	move_and_slide()


func _on_wander_timeout() -> void:
	agent.target_position = global_position + Vector2(
		randf_range(-3.0, 3.0),
		randf_range(-3.0, 3.0)
	) * 32.0
	state = State.Wander


func _on_shoot_timeout() -> void:
	var b := BULLET.instantiate() as Node2D
	get_parent().add_child(b)
	b.global_position = global_position
	b.direction = global_position.direction_to(goal.global_position)


func _on_stun_timeout() -> void:
	state = State.Idle
	wander.start(randf_range(2.0, 3.0))
	shoot.stop()
