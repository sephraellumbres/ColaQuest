#-----------------------------------------------------------------------------#
# Class Name:   game_UI.gd
# Description:  Holds functions for controlling the various aspects of the UI
# Author:       Rightin Yamada
# Company:      Sidetrack
# Last Updated: January 30, 2021
#-----------------------------------------------------------------------------#

extends Control
export var enable_hud: bool = true

#-----------------------------------------------------------------------------#
#                                 Signals                                     #
#-----------------------------------------------------------------------------#
# Signal that is activated when the player dies
signal player_killed         ()
# Signal that is activated when a level is cleared
signal level_cleared         ()
# Signal that is activated when the health of the player is changed
signal player_health_changed (current_health, previous_health)
# Signal that is activated when the health of the boss is changed 
signal boss_health_changed   (current_health, previous_health)
# Signal that is activated when the player has low health
signal player_low_health     ()
# Signal that is activated when the player is initiated
signal initialize_player     (max_health)
# Signal that is activated when the boss   is initiated
signal initialize_boss       (max_health, boss_name)
# Signal that is activated whenever the "retry" buttons are pressed
signal respawn_player        ()
# Signal that is activated when boss healthbar is shown
signal boss_healthbar_visible(visible)
# Flash the screen 
signal flash_screen          (color)
# Cola is being collected
signal cola_collect          (amount)
# On cola healing 
signal cola_healing          ()
# On healing enabled
signal healing_enabled       (enabled)
# Disable checkpoints
signal no_checkpoints         ()


#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#	
func on_no_checkpoints        () -> void:
	emit_signal("no_checkpoints")

# Emit signal on player killed 
func on_player_killed         () -> void:
	emit_signal("player_killed")

# Emit signal on level_cleared
func on_player_level_cleared  (previous_score: float) -> void:
	emit_signal("level_cleared", previous_score)

# Emit signal when player health changes
func on_player_health_changed (current_health, previous_health) -> void:
	emit_signal("player_health_changed", current_health, previous_health)

# Emit signal when boss health changes 
func on_boss_health_changed   (current_health, previous_health) -> void:
	emit_signal("boss_health_changed", current_health, previous_health)

# Emit signal when health is low
func on_player_low_health     () -> void:
	emit_signal("player_low_health")	

# Emit signal on player initialization
# Only the max health is being passed, more parameters may be sent in the future 
func on_initialize_player     (max_health) -> void:
	emit_signal("initialize_player", max_health)

# Emit signal on boss initialization
func on_initialize_boss       (max_health, boss_name) -> void:
	emit_signal("initialize_boss", max_health, boss_name)

# Emit signal when boss healthbar is shown
func on_boss_healthbar_visible(visible) -> void:
	emit_signal("boss_healthbar_visible", visible)

# Emit signal when screen needs flashing
func on_flash_screen          (color) -> void:
	emit_signal("flash_screen", color)

# Emit signal when cola is collected
func on_cola_collect          (amount) -> void:
	emit_signal("cola_collect", amount)

# Emit signal when healing is enabled or disabled
func on_healing_enabled       (enabled) -> void:
	emit_signal("healing_enabled", enabled)

# COMMENT NEEDED
func on_game_ui_visible (visible: bool) -> void:
	$HUD/ui_stat/stats.visible             = visible
	$HUD/ui_element/cola_counter.visible   = visible
	$HUD/ui_element/cola_healing.visible   = visible
	$player_healthbar/healthbar.visible    = visible
	
func get_cola_count() -> int:
	return $HUD.get_cola_count()
	
func get_respawn_count() -> int:
	return $HUD.get_respawn_count()

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#	
# Emit respawn signal when pause "retry" is pressed
func _on_pause_respawn_player() -> void:
	emit_signal("respawn_player")

# Emit respawn signal when failure "retry" is pressed
func _on_failure_respawn_player() -> void:
	emit_signal("respawn_player")

# On cola healing
func _on_HUD_cola_healing():
	emit_signal("cola_healing")
	
# COMMENT NEEDED
func _ready() -> void:
	on_game_ui_visible(true)
