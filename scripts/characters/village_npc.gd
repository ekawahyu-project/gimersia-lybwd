extends CharacterBody2D
## NPC warga desa Gimersia yang memiliki perilaku idle/patrol, animasi arah depan/belakang,
## indikator interaksi [E], serta status bar kepercayaan (barKepercayaan1..4).

signal clicked(npc: Node)

const TRUST_TEXTURES := {
	1: preload("res://assets/sprites/char/barKepercayaan/barKepercayaan1.png"),
	2: preload("res://assets/sprites/char/barKepercayaan/barKepercayaan2.png"),
	3: preload("res://assets/sprites/char/barKepercayaan/barKepercayaan3.png"),
	4: preload("res://assets/sprites/char/barKepercayaan/barKepercayaan4.png"),
}

const TRUST_LABELS := {
	1: "Dipercaya Warga",
	2: "Dikenal Warga",
	3: "Baru Mengenal",
	4: "Belum Dikenal",
}

@export var npc_id: String = "npc_1"
@export var npc_name: String = "Rina"
@export var npc_role: String = "Warga Perumahan"
@export var sprite_frames: SpriteFrames
@export var sprite_scale: float = 0.80
@export_range(1, 4) var trust_stage: int = 3
@export var move_speed: float = 26.0
@export var pause_duration: float = 2.6
@export var patrol_offsets: Array[Vector2] = []
@export var idle_look_around: bool = false
@export var dialogues: Array[String] = [
	"Halo! Selamat datang di desa Gimersia."
]

var _home_pos: Vector2
var _patrol_index: int = 0
var _wait_timer: float = 0.8
var _facing_up: bool = false
var _highlighted: bool = false
var _talking: bool = false
var _dialogue_cursor: int = 0
var _greeted_once: bool = false
var _bob_time: float = 0.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var status_overhead: Node2D = $StatusOverhead
@onready var trust_bar_sprite: Sprite2D = $StatusOverhead/TrustBarSprite
@onready var prompt_label: Label = $StatusOverhead/PromptLabel
@onready var click_area: Area2D = $ClickArea


func _ready() -> void:
	_home_pos = global_position
	if sprite_frames != null:
		sprite.sprite_frames = sprite_frames
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	status_overhead.visible = false
	_refresh_trust_visual()
	click_area.input_event.connect(_on_click_area_input_event)
	_play_idle()


func _physics_process(delta: float) -> void:
	_bob_time += delta * 3.0
	if _highlighted and status_overhead.visible:
		status_overhead.position.y = -39.0 + sin(_bob_time * 1.4) * 1.5

	if _talking or _highlighted:
		velocity = Vector2.ZERO
		_play_idle()
		return

	if patrol_offsets.size() >= 2:
		_process_patrol(delta)
	elif idle_look_around:
		_process_look_around(delta)
	else:
		velocity = Vector2.ZERO
		_play_idle()


func _process_patrol(delta: float) -> void:
	if _wait_timer > 0.0:
		_wait_timer -= delta
		velocity = Vector2.ZERO
		_play_idle()
		return

	var target := _home_pos + patrol_offsets[_patrol_index]
	var to_target := target - global_position
	if to_target.length() <= 3.0:
		global_position = target
		velocity = Vector2.ZERO
		_patrol_index = (_patrol_index + 1) % patrol_offsets.size()
		_wait_timer = pause_duration
		_play_idle()
		return

	var dir := to_target.normalized()
	velocity = dir * move_speed
	move_and_slide()
	if get_slide_collision_count() > 0:
		_patrol_index = (_patrol_index + 1) % patrol_offsets.size()
		_wait_timer = pause_duration
		_play_idle()
		return

	if absf(dir.y) > 0.15:
		_facing_up = dir.y < 0.0
	_play_walk()


func _process_look_around(delta: float) -> void:
	velocity = Vector2.ZERO
	_wait_timer -= delta
	if _wait_timer <= 0.0:
		_facing_up = not _facing_up
		_wait_timer = pause_duration + randf_range(0.4, 1.4)
	_play_idle()


## Mengatur apakah indikator interaksi dan bar kepercayaan di atas kepala NPC ditampilkan.
func set_interact_highlighted(active: bool) -> void:
	_highlighted = active
	status_overhead.visible = active and not _talking
	if active:
		_refresh_trust_visual()


## Menandai NPC sedang diajak berbicara dan mengarahkannya menghadap ke pemain.
func set_talking(talking: bool, player_pos: Vector2 = Vector2.ZERO) -> void:
	_talking = talking
	status_overhead.visible = _highlighted and not _talking
	if talking and player_pos != Vector2.ZERO:
		_facing_up = player_pos.y < global_position.y - 4.0
		_play_idle()


## Dipanggil ketika pemain menekan interaksi pada NPC; mengembalikan payload dialog.
func on_player_interact(player_pos: Vector2) -> Dictionary:
	set_talking(true, player_pos)
	if not _greeted_once:
		_greeted_once = true
		trust_stage = maxi(1, trust_stage - 1)
		_refresh_trust_visual()

	var text := "Halo! Senang bertemu denganmu di Gimersia."
	if not dialogues.is_empty():
		text = dialogues[_dialogue_cursor % dialogues.size()]
		_dialogue_cursor = (_dialogue_cursor + 1) % dialogues.size()

	return {
		"kind": "npc",
		"npc": self,
		"name": npc_name,
		"role": npc_role,
		"portrait": get_front_portrait(),
		"trust_texture": TRUST_TEXTURES.get(trust_stage, TRUST_TEXTURES[4]),
		"trust_label": TRUST_LABELS.get(trust_stage, "Pemula"),
		"text": text,
	}


## Mengembalikan tekstur potret menghadap depan dari SpriteFrames NPC ini.
func get_front_portrait() -> Texture2D:
	if sprite.sprite_frames != null and sprite.sprite_frames.has_animation("idle_down"):
		var frame_tex := sprite.sprite_frames.get_frame_texture("idle_down", 0)
		if frame_tex is AtlasTexture:
			var src := frame_tex as AtlasTexture
			var cropped := AtlasTexture.new()
			cropped.atlas = src.atlas
			cropped.region = Rect2(src.region.position + Vector2(12, 14), Vector2(40, 50))
			return cropped
		return frame_tex
	return null


func _refresh_trust_visual() -> void:
	trust_bar_sprite.texture = TRUST_TEXTURES.get(trust_stage, TRUST_TEXTURES[4])
	prompt_label.text = "[E] %s" % npc_name


func _play_walk() -> void:
	if sprite.sprite_frames == null:
		return
	var target_anim := "walk_up" if _facing_up else "walk_down"
	if not sprite.sprite_frames.has_animation(target_anim):
		target_anim = "idle_up" if _facing_up else "idle_down"
	if sprite.animation != target_anim:
		sprite.play(target_anim)


func _play_idle() -> void:
	if sprite.sprite_frames == null:
		return
	var target_anim := "idle_up" if _facing_up else "idle_down"
	if not sprite.sprite_frames.has_animation(target_anim):
		target_anim = "idle_down"
	if sprite.animation != target_anim:
		sprite.play(target_anim)


func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit(self)
