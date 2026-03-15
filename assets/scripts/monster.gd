extends CharacterBody2D

const BULLET := preload("uid://dxva2qkax7p66")

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var wander: Timer = $Wander
@onready var shoot: Timer = $Shoot

@export var goal: Node2D
@export var max_chase_distance := 400.0

enum State {
	Idle,
	Wander,
	Chase
}

var state := State.Idle

func _ready() -> void:
	wander.start(randf_range(2.0, 3.0))


func _physics_process(delta: float) -> void:
	match state:
		State.Idle: idle_process(delta)
		State.Wander: wander_process(delta)
		State.Chase: chase_process(delta)


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
	
	agent.target_position = goal.global_position
	
	var next := agent.get_next_path_position()
	
	velocity = global_position.direction_to(next) * 64.0
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
