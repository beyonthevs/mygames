class_name PortraitDialogueUI
extends Control

@export var portrait_rect: TextureRect
@export var name_label: Label
@export var dialogue_label: RichTextLabel
@export var background_panel: PanelContainer
@export var type_speed: float = 0.03

var is_typing: bool = false
var appearance_tween: Tween
var typing_tween: Tween

func _ready() -> void:
	hide()
	EventBus.dialogue_requested.connect(_on_dialogue_requested)

func _on_dialogue_requested(speaker_name: String, text: String, portrait: Texture2D) -> void:
	show()
	name_label.text = speaker_name
	dialogue_label.text = text
	
	if portrait:
		portrait_rect.texture = portrait
		
	_animate_portrait_entrance()
	_start_typing_effect(text)

func _animate_portrait_entrance() -> void:
	if appearance_tween and appearance_tween.is_running():
		appearance_tween.kill()
		
	# Setup initial offset and opacity
	portrait_rect.modulate.a = 0.0
	var initial_x: float = portrait_rect.position.x
	portrait_rect.position.x = initial_x - 60.0
	
	appearance_tween = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	appearance_tween.tween_property(portrait_rect, "modulate:a", 1.0, 0.4)
	appearance_tween.tween_property(portrait_rect, "position:x", initial_x, 0.4)

func _start_typing_effect(text: String) -> void:
	is_typing = true
	dialogue_label.visible_ratio = 0.0
	
	if typing_tween and typing_tween.is_running():
		typing_tween.kill()
		
	var duration: float = float(text.length()) * type_speed
	typing_tween = create_tween()
	typing_tween.tween_property(dialogue_label, "visible_ratio", 1.0, duration)
	typing_tween.finished.connect(func() -> void: is_typing = false)

func _input(event: InputEvent) -> void:
	if not visible:
		return
		
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		
		if is_typing:
			# Skip typewriter effect
			if typing_tween and typing_tween.is_running():
				typing_tween.kill()
			dialogue_label.visible_ratio = 1.0
			is_typing = false
		else:
			# Close dialogue and emit completion signal
			hide()
			EventBus.dialogue_finished.emit()
