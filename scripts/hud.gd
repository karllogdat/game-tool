extends CanvasLayer


const HEART_SIZE: int = 20

const HEART_FULL = preload("res://assets/images/UI/Heart_Full.png")
const HEART_HALF = preload("res://assets/images/UI/Heart_Half.png")
const HEART_EMPTY = preload("res://assets/images/UI/Heart_Empty.png")


var player

@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var hearts_container: HBoxContainer = $Hearts


func set_player(p) -> void:
	player = p

	if player:
		player.health_changed.connect(_update_health)
		_update_health(player.current_health)

func _update_health(new_health: int) -> void:
	var hearts = hearts_container.get_children()
	var max_hearts = len(hearts)

	var full = int(new_health / HEART_SIZE)
	var half = 1 if (new_health % HEART_SIZE) > 0 else 0
	var empty = max_hearts - (full + half) 

	# print("%d %d %d" % [full, half, empty])

	# update hearts
	for heart in hearts:
		if full > 0:
			heart.texture = HEART_FULL
			full -= 1
			continue
		
		if full == 0 and half > 0:
			heart.texture = HEART_HALF
			half -= 1
			continue

		if full == 0 and half == 0:
			heart.texture = HEART_EMPTY


func fade(to_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade_overlay, "modulate:a", to_alpha, 1.5)
	await tween.finished