extends Node2D


signal failed

export (PackedScene) var plane_packed
export (Array, PackedScene) var buildings_packed = []
export (PackedScene) var flag_packed

var can_liftoff = false
var taking_off = false
var is_airborn = false
var ready_to_land = false
var is_landing = false

onready var _balloon = $Balloon
onready var _background = $Background
onready var _plane_spawn_location = $PlanePath/PlaneSpawnLocation
onready var _building_spawn_location = $BuildingPath/BuildingSpawnLocation
onready var _progress = $ProgressPath/Progress

onready var _plane_timer = $Timers/PlaneTimer
onready var _building_timer = $Timers/BuildingTimer
onready var _gust_timer = $Timers/GustTimer
onready var _gust_stop_timer = $Timers/GustStopTimer
onready var _end_timer = $Timers/EndTimer
onready var _landing_timer = $Timers/LandingTimer

onready var _animation_player = $AnimationPlayer
onready var _landing_tween = $LandingTween

onready var _intro_tune = $Audio/IntroTunePlayer
onready var _music = $Audio/MusicPlayer
onready var _gust_audio = $Audio/GustAudioPlayer
onready var _clear_audio = $Audio/ClearAudioPlayer
onready var _ending_music = $Audio/EndingMusicPlayer
onready var _volume_tween = $Audio/VolumeTween


func _ready():
	randomize()
	_intro_tune.play()
	_animation_player.play("intro")


func _process(_delta):
	if can_liftoff and not is_airborn:
		process_liftoff()
	
	if is_airborn and not is_landing:
		process_progress()


func process_liftoff():
	if Input.is_action_pressed("burn"):
		if not _animation_player.is_playing():
			_animation_player.play("liftoff")
		elif not taking_off:
			_animation_player.stop(false)
		taking_off = true
	else:
		if not _animation_player.is_playing():
			_animation_player.play("liftoff", -1, -1.0)
		elif taking_off:
			_animation_player.stop(false)
		taking_off = false


func process_progress():
	var time_left =  _end_timer.time_left + (_landing_timer.wait_time if _landing_timer.is_stopped() else _landing_timer.time_left)
	var total_time = _end_timer.wait_time + _landing_timer.wait_time
	_progress.unit_offset = (total_time - time_left) / total_time


func start_gameplay():
	_background.start_scrolling()
	_music.play()
	_balloon.can_move = true
	_building_timer.start(5)
	_plane_timer.start(15)
	_gust_timer.start(40)
	_end_timer.start()
	is_airborn = true


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"intro":
			_balloon.can_burn = true
			can_liftoff = true
		"liftoff":
			if taking_off:
				start_gameplay()


func _on_Balloon_crashed():
	emit_signal("failed")


func _on_PlaneTimer_timeout():
	if ready_to_land:
		return
	
	_plane_spawn_location.offset = randi()
	
	var plane = plane_packed.instance()
	plane.position = _plane_spawn_location.position
	add_child(plane)
	
	_plane_timer.start(rand_range(8, 20))


func _on_BuildingTimer_timeout():
	if ready_to_land:
		return
	
	_building_spawn_location.offset = randi()
	
	var building_id = randi() % buildings_packed.size()
	var building = buildings_packed[building_id].instance()
	building.position = _building_spawn_location.position
	add_child(building)
	
	_building_timer.start(rand_range(2, 8))


func _on_GustTimer_timeout():
	if ready_to_land:
		return
	
	_gust_audio.play()
	
	_gust_stop_timer.start(1)
	yield(_gust_stop_timer, "timeout")
	
	_balloon.wind_blowing = true
	
	_gust_stop_timer.start(5.5)
	yield(_gust_stop_timer, "timeout")
	
	_balloon.wind_blowing = false
	
	_gust_timer.start(rand_range(20, 35))


func _on_EndTimer_timeout():
	ready_to_land = true
	_balloon.wind_blowing = false
	
	_landing_timer.start()
	
	_building_spawn_location.offset = 0
	
	var flag = flag_packed.instance()
	flag.position = _building_spawn_location.position
	add_child(flag)
	
	_volume_tween.interpolate_property(_music, "volume_db", null, -40, 10)
	_volume_tween.start()
	
	yield(_volume_tween, "tween_all_completed")
	
	_music.stop()
	_clear_audio.play()


func _on_ClearAudioPlayer_finished():
	_ending_music.play()


func _on_LinkButton_pressed():
	OS.shell_open("https://annie-66.eleven59.nl/")


func _on_LandingTimer_timeout():
	is_landing = true
	
	_balloon.can_move = false
	_balloon.can_burn = false
	_background.stop_scrolling()
	
	_animation_player.play("landing")
	
	_landing_tween.interpolate_property(_balloon, "position", null, Vector2(376, 768), 10)
	_landing_tween.interpolate_property(_balloon, "scale", null, Vector2(1, 1), 9)
	_landing_tween.start()
