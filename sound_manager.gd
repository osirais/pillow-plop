extends Node
class_name SoundManager

var audio_players: Array[AudioStreamPlayer] = []
var max_audio_players: int = 10

static var instance: SoundManager

func _ready():
	instance = self
	
	for i in range(max_audio_players):
		var player = AudioStreamPlayer.new()
		add_child(player)
		audio_players.append(player)

func play_combine_sound(level: int):
	var player = _get_available_player()
	if player:
		
		var pitch = 1.0 + (level - 1) * 0.1
		player.pitch_scale = pitch
		player.volume_db = -10

func play_drop_sound():
	var player = _get_available_player()
	if player:
		player.pitch_scale = 1.0
		player.volume_db = -15
		
		

func _get_available_player() -> AudioStreamPlayer:
	for player in audio_players:
		if not player.playing:
			return player
	return null
