extends Node2D

const MONSTER := preload("uid://qenc21ydshf7")

@onready var node_2d: Node2D = %Node2D
@onready var player: CharacterBody2D = $CharacterBody2D

var castle := Castlevania.new()

func _ready() -> void:
	for l in castle.generate():
		add_child.call_deferred(l)
	
	node_2d.castle = castle
	
	for p in castle._monster_spawns:
		var m := MONSTER.instantiate() as Node2D
		add_child(m)
		m.goal = player
		m.z_index = 64
		m.global_position = p


func _on_character_body_2d_killed() -> void:
	pass # Replace with function body.
