extends Node2D
## Pengendali scene utama peta desa Gimersia yang menghubungkan interaksi Player,
## warga desa (NPC), kelinci taman, serta antarmuka dialog HUD.

@onready var player: CharacterBody2D = $YSortProps/Player
@onready var character_hud: CanvasLayer = $CharacterHUD

var _active_npc: Node = null


func _ready() -> void:
	# Pastikan kamera milik pemain menjadi kamera aktif utama saat gameplay
	var map_cam := get_node_or_null("MapCamera") as Camera2D
	if map_cam != null:
		map_cam.enabled = false
		map_cam.set_process(false)
		map_cam.set_process_unhandled_input(false)

	if player != null:
		var p_cam := player.get_node_or_null("PlayerCamera") as Camera2D
		if p_cam != null:
			p_cam.enabled = true
			p_cam.make_current()
		player.interact_requested.connect(_on_player_interact_requested)

	if character_hud != null:
		character_hud.dialog_closed.connect(_on_dialog_closed)
		character_hud.next_dialog_requested.connect(_on_next_dialog_requested)

	for npc in get_tree().get_nodes_in_group("village_npcs"):
		if npc.has_signal("clicked"):
			npc.connect("clicked", _on_interactable_clicked)

	for rabbit in get_tree().get_nodes_in_group("garden_rabbits"):
		if rabbit.has_signal("clicked"):
			rabbit.connect("clicked", _on_interactable_clicked)


func _on_player_interact_requested(target: Node) -> void:
	if character_hud.is_dialog_open():
		return
	if target != null:
		_interact_with(target)


func _on_interactable_clicked(target: Node) -> void:
	if character_hud.is_dialog_open() or player == null or not is_instance_valid(target):
		return
	var target_pos := (target as Node2D).global_position
	if player.global_position.distance_to(target_pos) <= 52.0:
		_interact_with(target)
	else:
		character_hud.show_toast("Dekati terlebih dahulu untuk berinteraksi.", 1.6)


func _interact_with(target: Node) -> void:
	if not target.has_method("on_player_interact"):
		return
	var payload: Variant = target.call("on_player_interact", player.global_position)
	if not (payload is Dictionary):
		return
	var data := payload as Dictionary
	var kind := str(data.get("kind", ""))
	if kind == "npc":
		_active_npc = target
		player.face_toward((target as Node2D).global_position)
		player.set_movement_locked(true)
		character_hud.show_npc_dialog(data)
	elif kind == "rabbit":
		character_hud.show_toast(str(data.get("message", "")), 2.2)


func _on_next_dialog_requested() -> void:
	if is_instance_valid(_active_npc) and _active_npc.has_method("on_player_interact"):
		var data: Dictionary = _active_npc.call("on_player_interact", player.global_position)
		character_hud.show_npc_dialog(data)


func _on_dialog_closed() -> void:
	if is_instance_valid(_active_npc) and _active_npc.has_method("set_talking"):
		_active_npc.call("set_talking", false)
	_active_npc = null
	if player != null:
		player.set_movement_locked(false)
