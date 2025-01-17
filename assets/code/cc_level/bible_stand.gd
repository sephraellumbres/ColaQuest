#-----------------------------------------------------------------------------#
# File Name:    bible_stand.gd                                                #
# Description:  Activates the flooding animation of the first floor of the    #
#               Crowne Centre.                                                #
# Author:       Sephrael Lumbres                                              #
# Company:      Sidetrack                                                     #
# Last Updated: March 25, 2021                                                #
#-----------------------------------------------------------------------------#

extends Node2D

#-----------------------------------------------------------------------------#
#                            Onready Variables                                #
#-----------------------------------------------------------------------------#
onready var bible_verse: Node2D   = get_node("../bible_verse")
onready var camera:      Camera2D = get_node("../player/Camera2D")
onready var player:      Entity   = get_node("../player")
onready var tween:       Tween    = get_node("../water_shader/Tween")
onready var water:       Sprite   = get_node("../water_shader")
onready var state_machine         = $AnimationTree.get("parameters/playback")

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
var can_read_bible:         bool = false
var finished_reading_bible: bool = false

#-----------------------------------------------------------------------------#
#                               Input events                                  #
#-----------------------------------------------------------------------------#
func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_accept") or event.is_action_pressed("melee_attack")) and can_read_bible:
		bible_verse.get_node("../bible_verse/AnimationPlayer").play("transition")
		Globals.game_locked = true
		can_read_bible = false
	elif (event.is_action_pressed("ui_accept") or event.is_action_pressed("melee_attack")) and finished_reading_bible and $flooding_trigger/detection.disabled == false:
		bible_verse.get_node("../bible_verse/AnimationPlayer").play_backwards("transition")
		yield(bible_verse.get_node("../bible_verse/AnimationPlayer"), "animation_finished")
		camera.shake(5, 20, 15)
		state_machine.travel("bubble_shrink")

		Globals.player.set_speed(5)
		Globals.player.set_jump(300.0)
		Globals.player.set_is_underwater(true)
		Globals.player.set_max_fall_speed(300.0)
		player.max_jumps = 99
		
		$flooding_trigger/detection.disabled = true
		tween.interpolate_property(water, "position", Vector2(1525, 1000), Vector2(1525, 120), 5, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
		camera.limit_right     = 3840

#-----------------------------------------------------------------------------#
#                                Triggers                                     #
#-----------------------------------------------------------------------------#
func _on_flooding_trigger_body_entered(body: Node) -> void:
	if body.has_method("prepare_transition"):
		state_machine.travel("bubble_grow")
		can_read_bible = true

func _on_flooding_trigger_body_exited(body: Node) -> void:
	if body.has_method("prepare_transition"):
		state_machine.travel("bubble_shrink")
		can_read_bible = false


func _on_bible_verse_transition_complete() -> void:
	finished_reading_bible = true
	can_read_bible = false
