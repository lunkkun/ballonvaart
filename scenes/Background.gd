extends Node2D


onready var _animation_player = $AnimationPlayer


#func _ready():
#	start_scrolling()


func start_scrolling():
	_animation_player.play("scroll")


func stop_scrolling():
	_animation_player.stop()
