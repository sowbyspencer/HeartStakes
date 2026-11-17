# Store the player's current base max health.
execute store result score @s hs_max run attribute @s minecraft:max_health base get

# Notify the player and remove 1 health point (0.5 hearts) when at least 1 full heart remains.
execute if score @s hs_max matches ..1 run title @s actionbar {"text":"Death penalty: minimum 0.5 hearts","color":"dark_red"}
execute if score @s hs_max matches 2.. run title @s actionbar {"text":"Death penalty: -0.5 hearts","color":"dark_red"}
execute if score @s hs_max matches 2.. run scoreboard players remove @s hs_max 1

# Enforce a strict minimum of 1 health point (0.5 hearts).
execute if score @s hs_max matches ..0 run scoreboard players set @s hs_max 1
execute store result storage heartstakes:runtime max int 1 run scoreboard players get @s hs_max
function heartstakes:set_max_health with storage heartstakes:runtime

# Reset the trigger so this death is processed only once.
scoreboard players set @s hs_deaths 0
