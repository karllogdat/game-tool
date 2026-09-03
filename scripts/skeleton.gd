extends CharacterBody2D

const SPEED = 100.0

var target = null

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	if target:
		_attack(delta)

func _attack(delta: float) -> void:
	var direction = (target.position - position).normalized()
	position += direction * SPEED * delta
	
	animated_sprite_2d.flip_h = target.position.x < position.x
	animated_sprite_2d.play("run")

func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body

func _on_sight_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		target = null
		animated_sprite_2d.play("idle")
