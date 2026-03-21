extends Node

@onready var _stream_player: AudioStreamPlayer = AudioStreamPlayer.new()

# Fade settings
const FADE_DURATION := 0.8  # seconds

var _tween: Tween


func _ready() -> void:
	add_child(_stream_player)
	# Guard against missing bus — will fall back to Master
	if AudioServer.get_bus_index("Music") != -1:
		_stream_player.bus = "Music"
	else:
		push_warning("MusicManager: 'Music' bus not found, falling back to Master.")
		_stream_player.bus = "Master"
	_stream_player.finished.connect(_on_track_finished)


func _on_track_finished() -> void:
	_stream_player.play()


## Play a track. If the same track is already playing, does nothing.
## If a different track is playing, crossfades to the new one.
func play(stream: AudioStream, volume_db: float = 0.0) -> void:
	if _stream_player.stream == stream and _stream_player.playing:
		return

	if _stream_player.playing:
		_crossfade_to(stream, volume_db)
	else:
		_stream_player.stream = stream
		_stream_player.volume_db = volume_db
		_stream_player.play()


## Stop the current track, with an optional fade-out.
func stop(fade: bool = true) -> void:
	if not _stream_player.playing:
		return

	if fade:
		_fade_out()
	else:
		_stream_player.stop()


## Pause the current track.
func pause() -> void:
	_stream_player.stream_paused = true


## Resume a paused track.
func resume() -> void:
	_stream_player.stream_paused = false


## Returns true if a track is currently playing.
func is_playing() -> bool:
	return _stream_player.playing and not _stream_player.stream_paused


## Instantly set volume (in dB) of the current track.
func set_volume(volume_db: float) -> void:
	_stream_player.volume_db = volume_db


# ── Private helpers ──────────────────────────────────────────────────────────

func _crossfade_to(stream: AudioStream, volume_db: float) -> void:
	if _tween:
		_tween.kill()

	var original_volume := _stream_player.volume_db
	_tween = create_tween()

	# Fade out current track
	_tween.tween_property(_stream_player, "volume_db", -80.0, FADE_DURATION)

	# Swap stream and fade back in
	_tween.tween_callback(func():
		_stream_player.stop()
		_stream_player.stream = stream
		_stream_player.volume_db = -80.0
		_stream_player.play()
	)
	_tween.tween_property(_stream_player, "volume_db", volume_db, FADE_DURATION)


func _fade_out() -> void:
	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(_stream_player, "volume_db", -80.0, FADE_DURATION)
	_tween.tween_callback(_stream_player.stop)
