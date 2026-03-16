extends Control

@onready var resume: Button = $Panel/Resume
@onready var quit: Button = $Panel/Quit
@onready var world: Node2D = $"../.."

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func _process(delta: float) -> void:
	pass
	#if Input.is_action_just_pressed("pause"):
		#get_tree().paused = true
	#visible = true

func _on_resume_pressed() -> void:
	visible = false
	get_tree().paused = false
	visible = false

func _on_quit_pressed() -> void:
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://assets/scenes/main_menu.tscn")
