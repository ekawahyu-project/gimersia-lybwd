extends CharacterBody2D
## Kelinci taman interaktif di Area Taman yang memiliki animasi idle & lompat (hop).
## Dapat berkeliaran pendek di sekitar area bunga taman dan melompat menghindar saat didekati atau diklik.

signal clicked(rabbit: Node)

enum State { IDLE, WANDER_HOP, SCURRY }

@export var rabbit_name: String = "Kelinci Taman"
@export var wander_radius: float = 36.0
@export var hop_speed: float = 42.0
@export var scurry_speed: float = 88.0
@export var scare_distance: float = 16.0

var _home_pos: Vector2
var _state: State = State.IDLE
var _state_timer: float = 1.6
var _move_dir: Vector2 = Vector2.ZERO
var _highlighted: bool = false
var _player_ref: Node2D = null

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var prompt_label: Label = $PromptLabel
@onready var click_area: Area2D = $ClickArea


func _ready() -> void:
	_home_pos = global_position
	_state_timer = randf_range(0.8, 2.4)
	prompt_label.visible = false
	click_area.input_event.connect(_on_click_area_input_event)
	_player_ref = get_tree().get_first_node_in_group("player") as Node2D
	_play_idle()


func _physics_process(delta: float) -> void:
	if _state == State.IDLE and _player_ref == null:
		_player_ref = get_tree().get_first_node_in_group("player") as Node2D
	if _state == State.IDLE and is_instance_valid(_player_ref):
		if global_position.distance_to(_player_ref.global_position) < scare_distance:
			_trigger_scurry(_player_ref.global_position)

	match _state:
		State.IDLE:
			velocity = Vector2.ZERO
			_play_idle()
			_state_timer -= delta
			if _state_timer <= 0.0:
				_begin_wander_hop()
		State.WANDER_HOP:
			velocity = _move_dir * hop_speed
			move_and_slide()
			if get_slide_collision_count() > 0 or global_position.distance_to(_home_pos) > wander_radius + 8.0:
				_return_to_idle()
				return
			_state_timer -= delta
			if _state_timer <= 0.0:
				_return_to_idle()
		State.SCURRY:
			velocity = _move_dir * scurry_speed
			move_and_slide()
			if get_slide_collision_count() > 0:
				_move_dir = -_move_dir
				sprite.flip_h = _move_dir.x < 0.0
			_state_timer -= delta
			if _state_timer <= 0.0:
				_return_to_idle()


## Menampilkan indikator interaksi mini ketika pemain berada tepat di dekat kelinci.
func set_interact_highlighted(active: bool) -> void:
	_highlighted = active
	prompt_label.visible = active


## Dipanggil saat pemain berinteraksi dengan kelinci (mengusir / membuat kelinci melompat menjauh).
func on_player_interact(player_pos: Vector2) -> Dictionary:
	_trigger_scurry(player_pos)
	return {
		"kind": "rabbit",
		"message": "%s melompat lincah menjauhi bedeng bunga!" % rabbit_name,
	}


func _begin_wander_hop() -> void:
	var angle := randf() * TAU
	var target := _home_pos + Vector2(cos(angle), sin(angle)) * randf_range(12.0, wander_radius)
	var delta_vec := target - global_position
	if delta_vec.length() < 4.0:
		_return_to_idle()
		return
	_move_dir = delta_vec.normalized()
	_state = State.WANDER_HOP
	_state_timer = randf_range(0.45, 0.85)
	_play_hop(_move_dir)


func _trigger_scurry(from_pos: Vector2) -> void:
	var away := global_position - from_pos
	if away.length_squared() < 0.1:
		away = Vector2.RIGHT
	# Tetap tertarik sedikit ke home_pos agar tidak kabur terlalu jauh ke luar taman
	var pull_home := (_home_pos - global_position).normalized() * 0.25 if global_position.distance_to(_home_pos) > wander_radius else Vector2.ZERO
	_move_dir = (away.normalized() + pull_home).normalized()
	_state = State.SCURRY
	_state_timer = 0.72
	_play_hop(_move_dir)


func _return_to_idle() -> void:
	_state = State.IDLE
	_state_timer = randf_range(1.4, 3.2)
	velocity = Vector2.ZERO
	_play_idle()


func _play_idle() -> void:
	sprite.flip_h = false
	sprite.speed_scale = 1.0
	if sprite.animation != "idle":
		sprite.play("idle")


func _play_hop(dir: Vector2) -> void:
	# Asset KELINCI1..5 menghadap ke kanan secara native -> balik horizontal jika ke kiri
	sprite.flip_h = dir.x < -0.05
	sprite.speed_scale = 1.35 if _state == State.SCURRY else 1.0
	if sprite.animation != "hop":
		sprite.play("hop")


func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit(self)
