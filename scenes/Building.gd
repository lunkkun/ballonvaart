extends StaticBody2D


const SPEED = 110
const DESPAWN_X = -300


func _ready():
	add_to_group('buildings')


func _process(delta):
	position.x -= SPEED * delta
	
	if position.x < DESPAWN_X:
		get_parent().remove_child(self)
		queue_free()
