# @dummy
# @timeout 100

attribute @s minecraft:max_health base set 20
scoreboard players set @s hs_deaths 1
function heartstakes:on_death
assert score @s hs_max matches 19
assert score @s hs_deaths matches 0
succeed
