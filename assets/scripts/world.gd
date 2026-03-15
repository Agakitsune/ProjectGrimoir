extends Node2D

const MONSTER := preload("uid://qenc21ydshf7")
const CANDLE := preload("uid://cqrxkl5taxt48")

@onready var node_2d: Node2D = %Node2D
@onready var player: CharacterBody2D = %Player
@onready var maps: Node2D = %Maps

var castle := Castlevania.new()

func _ready() -> void:
	var map := castle.generate()
	for l in map:
		maps.add_child.call_deferred(l)
	
	node_2d.castle = castle
	
	for p in map[2].get_used_cells_by_id(3):
		var c := CANDLE.instantiate() as Node2D
		add_child(c)
		c.global_position = p * 32 + Vector2i(16, 16)
	
	for p in castle._monster_spawns:
		var m := MONSTER.instantiate() as Node2D
		add_child(m)
		m.goal = player
		m.z_index = 64
		m.global_position = p


func _on_character_body_2d_killed() -> void:
	pass # Replace with function body.
