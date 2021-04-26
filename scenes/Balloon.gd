extends Area2D


signal crashed

const BURN_ACCEL = -80
const MAX_BURN_SPEED = -80
const GRAVITY = 40
const MAX_FALL_SPEED = 40
const MIN_Y = 440
const MAX_Y = 780

const MIN_X = 260
const X_DECCEL = -40
const MAX_X_SPEED = -40
const WIND_ACCEL = 80
const MAX_WIND_SPEED = 60

export var can_burn = false
export var can_move = false

var vel = Vector2()
var burning = false setget set_burning
var punctured = false setget set_punctured
var wind_blowing = false

onready var _burning_animation = $BurningAnimation
onready var _punctured_sprite = $PuncturedSprite

onready var _burning_audio = $Audio/BurningAudioPlayer
onready var _punctured_audio = $Audio/PuncturedAudioPlayer
onready var _crashed_audio = $Audio/CrashedAudioPlayer


func set_punctured(val: bool):
	if val != punctured:
		punctured = val
		if punctured:
			_punctured_audio.play()
			_punctured_sprite.show()
		else:
			_punctured_sprite.hide()


func set_burning(val: bool):
	if val != burning:
		burning = val
		if burning:
			_burning_audio.play()
			_burning_animation.show()
		else:
			_burning_audio.stop()
			_burning_animation.hide()


func _process(delta: float):
	process_input()
	if can_move:
		process_movement(delta)


func process_input():
	if Input.is_action_pressed("burn") and can_burn:
		set_burning(true)
	else:
		set_burning(false)


func process_movement(delta: float):
	# Y
	
	if burning and not punctured:
		vel.y += BURN_ACCEL * delta
	else:
		vel.y += GRAVITY * delta

	vel.y = clamp(vel.y, MAX_BURN_SPEED, MAX_FALL_SPEED)
	
	position.y += vel.y * delta
	position.y = clamp(position.y, MIN_Y, MAX_Y)
	
	if position.y == MIN_Y or position.y == MAX_Y:
		vel.y = 0
	
	
	# X
	
	if wind_blowing:
		vel.x += WIND_ACCEL * delta
	elif position.x > MIN_X:
		vel.x += X_DECCEL * delta
	else:
		vel.x = 0
	
	vel.x = clamp(vel.x, MAX_X_SPEED, MAX_WIND_SPEED)
	
	position.x += vel.x * delta
	


func _on_Balloon_body_entered(body: PhysicsBody2D):
	if body.is_in_group("planes"):
		set_punctured(true)
	elif body.is_in_group("buildings"):
		_crashed_audio.play()
		emit_signal("crashed")
