extends Node

var current_track_path: String = ""
var music_player: AudioStreamPlayer

func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music" 
	add_child(music_player)
	
func play_music(path: String, volume_db := 0.0):
	if current_track_path == path:
		return 

	var stream = load(path) as AudioStream
	if not stream:
		push_error("Could not load music: %s" % path)
		return

	current_track_path = path
	music_player.stop()
	music_player.stream = stream
	music_player.volume_db = volume_db
	music_player.play()
