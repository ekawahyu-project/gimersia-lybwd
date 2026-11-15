extends Node2D
## Efek animasi halus untuk riak air sungai, kolam, dan aliran air terjun.

@export var bob_amplitude: float = 1.5
@export var bob_speed: float = 2.4
@export var pulse_alpha_min: float = 0.65
@export var pulse_alpha_max: float = 1.0
@export var phase_offset: float = 0.0

var _base_position: Vector2
var _time: float = 0.0


func _ready() -> void:
	_base_position = position
	_time = phase_offset


func _process(delta: float) -> void:
	_time += delta * bob_speed
	position.y = _base_position.y + sin(_time) * bob_amplitude
	var t := (sin(_time * 1.3) + 1.0) * 0.5
	modulate.a = lerpf(pulse_alpha_min, pulse_alpha_max, t)
