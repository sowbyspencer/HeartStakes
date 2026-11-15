# @dummy
# @timeout 100

attribute @s minecraft:max_health base set 20
scoreboard players set @s hs_deaths 1
await delay 2s
execute store result score @s hs_max run attribute @s minecraft:max_health base get
assert score @s hs_max matches 19
assert score @s hs_deaths matches 0
succeed
