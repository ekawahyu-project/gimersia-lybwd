extends CanvasLayer
## Antarmuka HUD karakter ringan untuk dialog NPC, bar kepercayaan, notifikasi kelinci,
## serta petunjuk kontrol navigasi desa Gimersia.

signal dialog_closed
signal next_dialog_requested

@onready var dialog_panel: PanelContainer = $DialogPanel
@onready var portrait_rect: TextureRect = $DialogPanel/Margin/HBox/PortraitFrame/PortraitRect
@onready var name_label: Label = $DialogPanel/Margin/HBox/Content/HeaderRow/NameLabel
@onready var role_label: Label = $DialogPanel/Margin/HBox/Content/HeaderRow/RoleLabel
@onready var trust_rect: TextureRect = $DialogPanel/Margin/HBox/Content/HeaderRow/TrustBox/TrustRect
@onready var trust_label: Label = $DialogPanel/Margin/HBox/Content/HeaderRow/TrustBox/TrustLabel
@onready var body_label: Label = $DialogPanel/Margin/HBox/Content/BodyLabel
@onready var next_button: Button = $DialogPanel/Margin/HBox/Content/ButtonRow/NextButton
@onready var close_button: Button = $DialogPanel/Margin/HBox/Content/ButtonRow/CloseButton
@onready var toast_panel: PanelContainer = $ToastPanel
@onready var toast_label: Label = $ToastPanel/Margin/ToastLabel

var _toast_timer: float = 0.0


func _ready() -> void:
	dialog_panel.visible = false
	toast_panel.visible = false
	next_button.pressed.connect(func() -> void: next_dialog_requested.emit())
	close_button.pressed.connect(hide_dialog)


func _process(delta: float) -> void:
	if toast_panel.visible and _toast_timer > 0.0:
		_toast_timer -= delta
		if _toast_timer <= 0.0:
			toast_panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not dialog_panel.visible:
		return
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo:
			if key_event.keycode == KEY_ESCAPE:
				hide_dialog()
				get_viewport().set_input_as_handled()
			elif key_event.keycode == KEY_E or key_event.keycode == KEY_ENTER or key_event.keycode == KEY_SPACE:
				next_dialog_requested.emit()
				get_viewport().set_input_as_handled()


## Menampilkan dialog NPC lengkap dengan potret dan status barKepercayaan.
func show_npc_dialog(payload: Dictionary) -> void:
	name_label.text = str(payload.get("name", "Warga Desa"))
	role_label.text = "— %s" % str(payload.get("role", "Warga"))
	body_label.text = str(payload.get("text", ""))
	portrait_rect.texture = payload.get("portrait", null)
	trust_rect.texture = _crop_trust_texture(payload.get("trust_texture", null))
	trust_label.text = str(payload.get("trust_label", ""))
	dialog_panel.visible = true


func _crop_trust_texture(raw_tex: Texture2D) -> Texture2D:
	if raw_tex == null:
		return null
	var cropped := AtlasTexture.new()
	cropped.atlas = raw_tex
	cropped.region = Rect2(2, 12, 29, 7)
	return cropped


## Menutup kotak dialog NPC yang sedang aktif.
func hide_dialog() -> void:
	if dialog_panel.visible:
		dialog_panel.visible = false
		dialog_closed.emit()


## Mengembalikan true bila kotak dialog NPC sedang tampil.
func is_dialog_open() -> bool:
	return dialog_panel.visible


## Menampilkan pesan toast singkat di atas layar (misal saat berinteraksi dengan kelinci).
func show_toast(message: String, duration: float = 2.4) -> void:
	toast_label.text = message
	toast_panel.visible = true
	_toast_timer = duration
