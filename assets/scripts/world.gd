extends Node2D

const MONSTER := preload("uid://qenc21ydshf7")
const CANDLE := preload("uid://cqrxkl5taxt48")
const EXIT := preload("uid://cn8ccew8sv87u")

@onready var node_2d: Node2D = %Node2D
@onready var player: CharacterBody2D = %Player
@onready var maps: Node2D = %Maps
@onready var pause_menu: Control = $CanvasLayer/PauseMenu
@onready var control: Control = $CanvasLayer2/Control
@onready var castle_killer: Timer = $CastleKiller

var castle := Castlevania.new()

var _kill := 0

func _ready() -> void:
	castle_killer.start()
	gen()

func gen():
	var map := castle.generate()
	for l in map:
		maps.add_child.call_deferred(l)
	
	castle_killer.stop()
	
	node_2d.castle = castle
	
	for p in map[2].get_used_cells_by_id(3):
		var c := CANDLE.instantiate() as Node2D
		add_child(c)
		c.global_position = p * 32 + Vector2i(16, 16)
	
	for p in castle._monster_spawns:
		var m := MONSTER.instantiate() as Node2D
		m.killed.connect(_on_monster_killed.bind(m))
		maps.add_child(m)
		m.goal = player
		m.z_index = 64
		m.global_position = p


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_menu.visible = true
		get_tree().paused = true


func _on_monster_killed(s: Node2D) -> void:
	_kill += 1
	
	if _kill == castle._monster_spawns.size():
		var e := EXIT.instantiate()
		s.get_parent().add_child(e)
		e.global_position = s.global_position
		#get_tree().change_scene_to_file("res://assets/scenes/world.tscn")


func _on_character_body_2d_killed() -> void:
	control.visible = true
	get_tree().paused = true


func _on_quit_pressed() -> void:
	control.visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://assets/scenes/main_menu.tscn")


func _on_retry_pressed() -> void:
	control.visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://assets/scenes/world.tscn")


func _on_castle_killer_timeout() -> void:
	castle_killer.start()
	gen()
