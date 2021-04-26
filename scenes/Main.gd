extends Node2D


export (PackedScene) var stage_packed

var stage: Node2D

onready var _world = $World
onready var _game_over_screen = $Control/GameOverScreen
onready var _game_over_label = $Control/GameOverLabel
onready var _reset_button = $Control/ResetButton
onready var _tween = $Control/Tween


func _ready():
	load_stage()


func load_stage():
	stage = stage_packed.instance()
	_world.add_child(stage)
	
	stage.connect("failed", self, "_on_Stage_failed")


func _on_Stage_failed():
	get_tree().paused = true
	
	_tween.interpolate_property(_game_over_screen, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 2)
	_tween.interpolate_property(_game_over_label, "custom_colors/font_color", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 2)
	_tween.interpolate_property(_reset_button, "custom_colors/font_color", Color(0.7, 0.7, 0.7, 0), Color(0.7, 0.7, 0.7, 1), 2)
	_tween.start()
	
	_reset_button.disabled = false


func _on_ToolButton_pressed():
	_tween.stop_all()
	
	_reset_button.disabled = true
	_game_over_screen.color = Color(0, 0, 0, 0)
	_game_over_label.set("custom_colors/font_color", Color(1, 1, 1, 0))
	
	_world.remove_child(stage)
	stage.queue_free()
	
	load_stage()
	
	get_tree().paused = false
