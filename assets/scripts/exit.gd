extends Area2D

@onready var timer: Timer = $Timer


func _on_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://assets/scenes/world.tscn")
