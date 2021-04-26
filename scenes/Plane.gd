extends KinematicBody2D


const MIN_SPEED = 120
const MAX_SPEED = 180
const DESPAWN_X = 0

var despawning = false

onready var speed = rand_range(MIN_SPEED, MAX_SPEED)
onready var _audio = $AudioStreamPlayer2D
onready var _volume_tween = $VolumeTween


func _ready():
	_volume_tween.interpolate_property(_audio, "volume_db", -30, 10, 2)
	_volume_tween.start()


func _process(delta):
	position.x -= speed * delta
	
	if position.x < DESPAWN_X and not despawning:
		despawning = true
		despawn()


func despawn():
	_volume_tween.interpolate_property(_audio, "volume_db", 10, -30, 2)
	_volume_tween.start()
	
	yield(_volume_tween, "tween_all_completed")
	
	get_parent().remove_child(self)
	queue_free()
