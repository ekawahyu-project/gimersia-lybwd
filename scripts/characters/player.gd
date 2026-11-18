extends CharacterBody2D
## Karakter utama (Player) yang dapat dikendalikan di peta desa Gimersia.
## Mendukung gerak 8 arah (WASD/Panah), sprint (Shift), deteksi interaksi (E/klik),
## serta kontrol zoom dan toggle kamera penuh (V/Scroll).

signal interact_requested(target: Node)
signal nearest_interactable_changed(target: Node)

@export var walk_speed: float = 95.0
@export var sprint_speed: float = 155.0
@export var gameplay_zoom: float = 1.85
@export var overview_zoom: float = 0.96
@export var zoom_step: float = 0.2
@export var min_zoom: float = 0.95
@export var max_zoom: float = 3.0
@export var map_size: Vector2 = Vector2(1204.0, 672.0)

var movement_locked: bool = false
var _facing_up: bool = false
var _is_overview: bool = false
var _current_target: Node = null
var _nearby_targets: Array[Node] = []

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var interact_detector: Area2D = $InteractDetector
@onready var camera: Camera2D = $PlayerCamera


func _ready() -> void:
	interact_detector.body_entered.connect(_on_detector_body_entered)
	interact_detector.body_exited.connect(_on_detector_body_exited)
	interact_detector.area_entered.connect(_on_detector_area_entered)
	interact_detector.area_exited.connect(_on_detector_area_exited)
	get_viewport().size_changed.connect(_update_overview_zoom)
	_update_overview_zoom()
	_apply_camera_zoom(gameplay_zoom)
	_play_idle()


func _physics_process(_delta: float) -> void:
	if movement_locked:
		velocity = Vector2.ZERO
		_play_idle()
		return

	var input_dir := _read_movement_input()
	var sprinting := Input.is_key_pressed(KEY_SHIFT)
	var speed := sprint_speed if sprinting else walk_speed
	velocity = input_dir * speed
	move_and_slide()

	_update_animation(velocity, sprinting)
	_refresh_nearest_target()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo:
			if key_event.keycode == KEY_E:
				if movement_locked:
					return
				_trigger_interact()
				get_viewport().set_input_as_handled()
			elif key_event.keycode == KEY_V or key_event.keycode == KEY_R:
				if not movement_locked:
					toggle_overview()
					get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed:
			if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_is_overview = false
				_apply_camera_zoom(camera.zoom.x + zoom_step)
			elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_is_overview = false
				_apply_camera_zoom(camera.zoom.x - zoom_step)


## Mengganti antara mode zoom gameplay mengikuti karakter dan tampilan penuh seluruh desa.
func toggle_overview() -> void:
	_is_overview = not _is_overview
	if _is_overview:
		_update_overview_zoom()
		_apply_camera_zoom(overview_zoom)
	else:
		_apply_camera_zoom(gameplay_zoom)


## Mengatur apakah gerakan pemain dikunci (misalnya saat kotak dialog NPC terbuka).
func set_movement_locked(locked: bool) -> void:
	movement_locked = locked
	if locked:
		velocity = Vector2.ZERO
		_play_idle()


## Mengarahkan hadap pemain ke titik tertentu (misalnya menghadap NPC saat berbicara).
func face_toward(target_pos: Vector2) -> void:
	_facing_up = target_pos.y < global_position.y - 4.0
	_play_idle()


func _read_movement_input() -> Vector2:
	var dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		dir.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		dir.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
		dir.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
		dir.y += 1.0
	return dir.normalized() if dir.length_squared() > 0.0 else Vector2.ZERO


func _update_animation(vel: Vector2, sprinting: bool) -> void:
	if vel.length_squared() <= 1.0:
		_play_idle()
		return

	if vel.y < -4.0:
		_facing_up = true
	elif vel.y > 4.0:
		_facing_up = false

	sprite.speed_scale = 1.45 if sprinting else 1.0
	var anim := "walk_up" if _facing_up else "walk_down"
	if sprite.animation != anim:
		sprite.play(anim)


func _play_idle() -> void:
	sprite.speed_scale = 1.0
	var anim := "idle_up" if _facing_up else "idle_down"
	if sprite.animation != anim:
		sprite.play(anim)


func _trigger_interact() -> void:
	if is_instance_valid(_current_target):
		interact_requested.emit(_current_target)
	elif movement_locked:
		interact_requested.emit(null)


func _refresh_nearest_target() -> void:
	var best: Node = null
	var best_dist_sq := INF
	var cleaned: Array[Node] = []

	for candidate in _nearby_targets:
		if not is_instance_valid(candidate):
			continue
		cleaned.append(candidate)
		var dist_sq := global_position.distance_squared_to((candidate as Node2D).global_position)
		if dist_sq < best_dist_sq:
			best_dist_sq = dist_sq
			best = candidate

	_nearby_targets = cleaned
	if best != _current_target:
		if is_instance_valid(_current_target) and _current_target.has_method("set_interact_highlighted"):
			_current_target.call("set_interact_highlighted", false)
		_current_target = best
		if is_instance_valid(_current_target) and _current_target.has_method("set_interact_highlighted"):
			_current_target.call("set_interact_highlighted", true)
		nearest_interactable_changed.emit(_current_target)


func _register_candidate(node: Node) -> void:
	var owner_node := _resolve_interactable_owner(node)
	if owner_node != null and owner_node != self and owner_node not in _nearby_targets:
		_nearby_targets.append(owner_node)


func _unregister_candidate(node: Node) -> void:
	var owner_node := _resolve_interactable_owner(node)
	if owner_node != null and owner_node in _nearby_targets:
		_nearby_targets.erase(owner_node)


func _resolve_interactable_owner(node: Node) -> Node:
	if node == null:
		return null
	if node.has_method("on_player_interact"):
		return node
	var p := node.get_parent()
	if p != null and p.has_method("on_player_interact"):
		return p
	return null


func _on_detector_body_entered(body: Node2D) -> void:
	_register_candidate(body)


func _on_detector_body_exited(body: Node2D) -> void:
	_unregister_candidate(body)


func _on_detector_area_entered(area: Area2D) -> void:
	_register_candidate(area)


func _on_detector_area_exited(area: Area2D) -> void:
	_unregister_candidate(area)


func _update_overview_zoom() -> void:
	var vp := get_viewport_rect().size
	if vp.x <= 0.0 or vp.y <= 0.0:
		return
	overview_zoom = clampf(minf(vp.x / map_size.x, vp.y / map_size.y), 0.5, gameplay_zoom)
	if _is_overview:
		_apply_camera_zoom(overview_zoom)


func _apply_camera_zoom(target_zoom: float) -> void:
	var min_allowed := minf(min_zoom, overview_zoom)
	var clamped := clampf(target_zoom, min_allowed, max_zoom)
	camera.zoom = Vector2(clamped, clamped)
