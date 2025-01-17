#-----------------------------------------------------------------------------#
# Class Name:   hud.gd
# Description:  Controls elements on the in-game UI
# Author:       Rightin Yamada                
# Company:      Sidetrack
# Last Updated: March 18, 2021
#-----------------------------------------------------------------------------#

extends Control

#-----------------------------------------------------------------------------#
#                                 Signals                                     #
#-----------------------------------------------------------------------------#
# Emitted when cola healing occurs
signal cola_healing()

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
onready var green_plus    = $ui_element/cola_healing/green_plus
onready var green_plus_ss = $ui_element/cola_healing/green_plus_ss


# Counts the amount of respawns
var _respawn_count:    int = 0

# Counts the amount of cola collected 
var _cola_count:       int = 0

# Number of cola required for healing to occur
var _cola_requirement: int = 5

# Maximum player health
var _m_health:         int  = 0

# Current player health
var _c_health:         int  = 0

var _healing_enabled:  bool = true

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
# Hide respawn counter by default
func _ready() -> void:
	_cola_count       = PlayerVariables.saved_cola
	_respawn_count    = PlayerVariables.saved_deaths
	green_plus.value  = PlayerVariables.saved_health
	$ui_stat/stats/respawn_counter.visible          = false
	$ui_stat/stats/total_cola_collected.visible     = false
	$ui_stat/stats/time_taken.visible               = false
	$ui_stat/stats/score.visible                    = false
	$ui_stat/stats/highscore.visible                = false
	$ui_stat/stats/respawn_counter_on_death.visible = false
	green_plus.max_value  = _cola_requirement
	green_plus.value      = 0
	green_plus_ss.visible = false

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
# Keep ui statistics updated
func _physics_process(_delta: float) -> void:
	$ui_element/cola_counter/cola_collected.set_text (" " + str(_cola_count))
	$ui_stat/stats/fps_counter.set_text              ("FPS: " + str(Engine.get_frames_per_second()))
	$ui_stat/stats/total_cola_collected.set_text     ("Cola Collected: " + str(_cola_count) + " (score: " + str(int(_cola_count * Globals.HIGHSCORE_WEIGHTS.COLA)) + ")")
	$ui_stat/stats/respawn_counter.set_text          ("Respawn Counter: " + str(_respawn_count) + " (score: " + str(int(_respawn_count * Globals.HIGHSCORE_WEIGHTS.DEATH)) + ")")
	$ui_stat/stats/time_taken.set_text               ("Time Taken: " + _float2time(Globals.get_highscore_timer()) + " (score: " + str(int(Globals.get_highscore_timer() * Globals.HIGHSCORE_WEIGHTS.SECOND)) + ")")
	$ui_stat/stats/score.set_text                    ("____________________\nScore: " + str(int(Globals.calculate_highscore(_cola_count, Globals.get_highscore_timer(), _respawn_count))))

func get_cola_count() -> int:
	return _cola_count
	
func get_respawn_count() -> int:
	return _respawn_count
	
func _float2time(value: float) -> String:
# warning-ignore:integer_division
	var minutes: int = int(value) / 60
	var seconds: int = int(value) % 60
	return ("%02d" % minutes) + ":" + ("%02d" % seconds)

#-----------------------------------------------------------------------------#
#                             Trigger Functions                               #
#-----------------------------------------------------------------------------#
# On player killed, show respawn counter
func _on_game_UI_player_killed() -> void:
	yield(get_tree().create_timer(1.0), "timeout")
	$ui_stat/stats/respawn_counter_on_death.set_text("Deaths: " + str(_respawn_count + 1))
	$ui_stat/stats/respawn_counter_on_death.visible = true

# On player respawn, increment respawn counter
func _on_game_UI_respawn_player() -> void:
	_healing_enabled      = true
	green_plus.value      =  0
	green_plus_ss.visible = false
	_respawn_count               += 1
	PlayerVariables.saved_deaths += 1
	$ui_stat/stats/respawn_counter_on_death.visible = false
	$ui_stat/stats/total_cola_collected.visible     = false

# On game cleared, show level stats
func _on_game_UI_level_cleared(previous_score: float):
	yield(get_tree().create_timer(3.0), "timeout")
	$ui_stat/stats/total_cola_collected.visible  = true
	$ui_stat/stats/respawn_counter.visible       = true
	$ui_stat/stats/time_taken.visible            = true
	$ui_stat/stats/score.visible                 = true
	
	if Globals.calculate_highscore(_cola_count, Globals.get_highscore_timer(), _respawn_count) > previous_score:
		$ui_stat/stats/highscore.visible         = true

# On collecting a cola(s)
func _on_game_UI_cola_collect(amount):
	_cola_count += amount
	$ui_element/cola_counter/cola_tween.interpolate_property($ui_element/cola_counter/cola_icon, "scale", Vector2(2,2), Vector2(1,1), .5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$ui_element/cola_counter/cola_tween.start()
	if _healing_enabled:
		green_plus.value += amount
		if (green_plus.value == _cola_requirement):
			green_plus_ss.visible = true
			green_plus.visible    = false
		if (green_plus.value == _cola_requirement) and (Globals.player.get_current_health() != Globals.player.get_max_health()):
			_cola_healing()

# On initialization
func _on_game_UI_initialize_player(max_health) -> void:
	_m_health = max_health
	_c_health = max_health

# On player health changing
func _on_game_UI_player_health_changed(_current_health, _previous_health) -> void:
	_c_health = _current_health
	if _healing_enabled == true:
		if (green_plus.value == _cola_requirement) and (_current_health < _previous_health):
			_cola_healing()

# On cola healing the player
func _cola_healing():
	emit_signal("cola_healing")
	green_plus.value      = 0
	green_plus_ss.visible = false
	green_plus.visible    = true

# On healing enabled
func _on_game_UI_healing_enabled(enabled):
	_healing_enabled = enabled
