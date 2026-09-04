extends CharacterBody2D

const SPEED: int = 100
const KNOCKBACK_FORCE: int = 100

var damage: int = 20

var is_alive: bool = true
var health: int = 100
var target = null
var target_in_range: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var take_damage_sfx: AudioStreamPlayer2D = $TakeDamage
@onready var health_bar: Node2D = $HealthBar
@onready var attack_timer: Timer = $AttackTimer


func _physics_process(delta: float) -> void:
	if is_alive and target:
		_attack(delta)

func _attack(delta: float) -> void:
	var direction = (target.position - position).normalized()
	position += direction * SPEED * delta
	
	animated_sprite_2d.flip_h = target.position.x < position.x
	animated_sprite_2d.play("run")

func take_damage(damage: int, attacker_position: Vector2) -> void:
	health -= damage
	health_bar.update_health(health)

	if health <= 0:
		_die()

	take_damage_sfx.play()

	# knockback
	var knockback_dir = (position - attacker_position).normalized()
	var target_position = position + knockback_dir * KNOCKBACK_FORCE

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", target_position, 0.5)

func _die() -> void:
	is_alive = false

	animated_sprite_2d.play("die")
	health_bar.visible = false

	take_damage_sfx.pitch_scale = 0.5
	take_damage_sfx.play()

	# disable collision
	$Hitbox.set_deferred("disabled", true)
	$Sight/CollisionShape2D.set_deferred("disabled", true)

func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body

func _on_sight_body_exited(body: Node2D) -> void:
	if body.name == "Player" and is_alive:
		target = null
		animated_sprite_2d.play("idle")

func _on_attack_box_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target_in_range = true
		body.take_damage(damage)
		attack_timer.start()

func _on_attack_box_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		target_in_range = false
		attack_timer.stop()

func _on_attack_timer_timeout() -> void:
	if target and target_in_range:
		target.take_damage(damage)
