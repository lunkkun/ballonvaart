extends Node2D


const SPEED = 110


func _process(delta):
	position.x -= SPEED * delta
