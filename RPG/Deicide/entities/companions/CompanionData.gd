class_name CompanionData
extends Resource

@export_enum("lyra_sainz", "clay_roche", "sibyl_thorne") var id: StringName = &"lyra_sainz"
@export var display_name: String = ""
@export var hair_color_code: Color = Color.WHITE
@export var default_portrait: Texture2D
@export var blushing_portrait: Texture2D
@export var threat_portrait: Texture2D
@export var affinity_score: int = 0
@export var story_flags: Dictionary = {}

func add_affinity(amount: int) -> void:
	affinity_score += amount

func check_story_flag(flag: String) -> bool:
	return story_flags.get(flag, false) as bool
