extends CharacterBody2D

signal died

@export var SPEED = 300.0

var is_alive: bool = true
var max_health: int
var current_health: int
var damage: int = 30

var last_direction: Vector2 = Vector2.DOWN
var is_attacking: bool = false
var hitbox_offset: Vector2

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var damage_cooldown: Timer = $DamageCooldown

@onready var swing_sword: AudioStreamPlayer2D = $SwingSword
@onready var take_damage_sfx: AudioStreamPlayer2D = $TakeDamage


func _ready() -> void:
	# load health from singleton
	max_health = PlayerStats.max_health
	current_health = PlayerStats.current_health

	# initialize hitbox offset 
	hitbox_offset = hitbox.position


func _physics_process(_delta: float) -> void:
	# disable hitbox until attack is triggered
	hitbox.monitoring = false

	if not is_alive:
		return

	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()

	# skip movement if attacking
	if is_attacking:
		velocity = Vector2.ZERO
		return

	process_movement()
	process_animation()
	move_and_slide()

# ----- MOVEMENT AND ANIMATION -----
func process_movement() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")

	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
		update_hitbox_offset()
	else:
		velocity = Vector2.ZERO


func process_animation() -> void:
	if is_attacking:
		return

	if velocity != Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)


func play_animation(prefix:String, dir: Vector2) -> void:
	if dir.x > 0:
		animated_sprite_2d.play(prefix + "_right")
	elif dir.x < 0:
		animated_sprite_2d.play(prefix + "_left")
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_down")

# ----- ATTACK -----
func attack() -> void:
	is_attacking = true
	hitbox.monitoring = true
	swing_sword.play()
	play_animation("attack", last_direction)

func _on_animated_sprite_2d_animation_finished() -> void:
	is_attacking = false

func take_damage(damage: int) -> void:
	if not is_alive:
		return

	if damage_cooldown.time_left > 0:
		return
	
	current_health -= damage
	PlayerStats.current_health = current_health

	take_damage_sfx.play()

	if current_health <= 0:
		die()

	# invincibility cooldown
	damage_cooldown.start()

	print("Player health: %s" % current_health)

func die() -> void:
	animated_sprite_2d.play("die")
	is_alive = false
	
	await animated_sprite_2d.animation_finished

	died.emit()
	

# ----- HITBOX -----
func update_hitbox_offset() -> void:
	var x := hitbox_offset.x
	var y := hitbox_offset.y 

	match last_direction:
		Vector2.UP:
			hitbox.position = Vector2(x, y)
		Vector2.DOWN:
			hitbox.position = Vector2(x, -y)
		Vector2.LEFT:
			hitbox.position = Vector2(y, -x)
		Vector2.RIGHT:
			hitbox.position = Vector2(-y, x)

# attack 
func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_attacking and body.name.begins_with("Skeleton"):
		body.take_damage(damage, position)
		print("Enemy hit: " + body.name + " for " + str(damage))
