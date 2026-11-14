# Revoke immediately so every enchanted golden apple can trigger this advancement.
advancement revoke @s only heartstakes:eat_enchanted_apple

# Add 2 health points (1 full heart) to the current base max health.
execute store result score @s hs_max run attribute @s minecraft:max_health base get
scoreboard players add @s hs_max 2
execute store result entity @s attributes[{id:"minecraft:max_health"}].base double 1 run scoreboard players get @s hs_max

# Give subtle positive feedback.
playsound minecraft:entity.player.levelup player @s ~ ~ ~ 0.5 1.2
title @s actionbar {"text":"+1 heart","color":"gold"}
