extends Camera2D
## Kamera inspeksi peta desa Gimersia.
## Memuat tampilan penuh peta saat dimulai dan mendukung pan (WASD/Panah/drag) serta zoom (scroll).

@export var map_size: Vector2 = Vector2(1344.0, 784.0)
@export var pan_speed: float = 420.0
@export var zoom_step: float = 0.15
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0

var _fit_zoom: float = 0.82
var _dragging: bool = false


func _ready() -> void:
	_compute_fit_zoom()
	reset_view()
	get_viewport().size_changed.connect(_on_viewport_size_changed)


func _process(delta: float) -> void:
	var direction := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	if Input.is_key_pressed(KEY_A):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_W):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		direction.y += 1.0

	if direction.length_squared() > 0.0:
		direction = direction.normalized()
		global_position += direction * (pan_speed / zoom.x) * delta
		_clamp_to_map()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP and mouse_event.pressed:
			_apply_zoom(zoom.x + zoom_step)
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN and mouse_event.pressed:
			_apply_zoom(zoom.x - zoom_step)
		elif mouse_event.button_index == MOUSE_BUTTON_MIDDLE or mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			_dragging = mouse_event.pressed
	elif event is InputEventMouseMotion and _dragging:
		var motion := event as InputEventMouseMotion
		global_position -= motion.relative / zoom.x
		_clamp_to_map()
	elif event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_R:
			reset_view()


## Mengembalikan posisi dan zoom kamera agar seluruh peta terlihat utuh.
func reset_view() -> void:
	_compute_fit_zoom()
	zoom = Vector2(_fit_zoom, _fit_zoom)
	global_position = map_size * 0.5


func _compute_fit_zoom() -> void:
	var vp_size := get_viewport_rect().size
	if vp_size.x <= 0.0 or vp_size.y <= 0.0:
		return
	_fit_zoom = clampf(minf(vp_size.x / map_size.x, vp_size.y / map_size.y), min_zoom, max_zoom)


func _apply_zoom(target: float) -> void:
	var clamped := clampf(target, min_zoom, max_zoom)
	zoom = Vector2(clamped, clamped)
	_clamp_to_map()


func _clamp_to_map() -> void:
	global_position = global_position.clamp(Vector2.ZERO, map_size)


func _on_viewport_size_changed() -> void:
	_compute_fit_zoom()
