extends CharacterBody2D

const SPEED = 70

const FIRE_BALL_SPELL = preload("uid://w10kyeikbffb")
const LIGHTNING_BOLT_SPELL = preload("res://assets/scenes/spell/lightning_bolt_spell.tscn")
const FIRE_SLASH = preload("res://assets/scenes/spell/fire_slash.tscn")
const SPELL_UI = preload("res://assets/scenes/spell_ui.tscn")

@onready var health_bar: ProgressBar = $HealthBar
@onready var misc: Node2D = %MiscX

signal killed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	unlock_spell("fireball")
	unlock_spell("fireslash")
	unlock_spell("lightning")

func _physics_process(delta: float) -> void:
	var vec := Input.get_vector("left", "right", "up", "down").normalized() * 4.0
	velocity = vec * 32.0
	
	move_and_slide()
	
	position = position.snappedf(1.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	for spell_name in spells:
		var spell = spells[spell_name]
		if not spell.unlocked or spell.ui.current_cooldown > 0:
			continue
		if Input.is_action_just_pressed(spell.action):
			if spell.ui:
				spell.ui.set_cooldown()
			var spell_instance = spell.scene.instantiate() as Node2D
			if spell.fixed:
				add_child(spell_instance)
			else:
				get_parent().add_child(spell_instance)
				#spell_instance.global_position = global_position
				#spell_instance.direction = global_position.direction_to(get_local_mouse_position())
			spell_instance.setup(self, mouse_pos)

func add_pv(value):
	health_bar.value += value

func sub_pv(value):
	health_bar.value -= value
	if health_bar.value <= 0:
		killed.emit()

var spells = {
	"fireball": {
		"scene": FIRE_BALL_SPELL,
		"action": "e_spell",
		"action_key": "E",
		"texture": "res://assets/textures/fireball.png",
		"cooldown": 0.25,
		"unlocked": false,
		"ui": null,
		"fixed": false
	},
	"fireslash": {
		"scene": FIRE_SLASH,
		"action": "f_spell",
		"action_key": "F",
		"texture": "res://assets/textures/fireslash.png",
		"cooldown": 4,
		"unlocked": false,
		"ui": null,
		"fixed": true
	},
	"lightning": {
		"scene": LIGHTNING_BOLT_SPELL,
		"action": "q_spell",
		"action_key": "Q",
		"texture": "res://assets/textures/lightningbolt.png",
		"cooldown": 3,
		"unlocked": false,
		"ui": null,
		"fixed": false
	}
}

func unlock_spell(spell_name:String):
	if not spells.has(spell_name):
		return
	var spell = spells[spell_name]

	if spell.unlocked:
		return
	spell.unlocked = true
	var spell_ui = SPELL_UI.instantiate()
	add_child(spell_ui)
	spell_ui.setup(spell.texture, spell.action_key, spell.cooldown)
	spell_ui.z_index = 15
	spell.ui = spell_ui
	var index = spell_ui.get_index()
	spell_ui.position = Vector2(-350 + 50 * index , 70)
	spell_ui.scale = Vector2(1,1)
