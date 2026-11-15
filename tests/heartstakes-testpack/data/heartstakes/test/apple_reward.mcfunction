# @dummy
# @timeout 100

attribute @s minecraft:max_health base set 20
function heartstakes:on_eat_apple
await delay 1t
execute store result score @s hs_max run attribute @s minecraft:max_health base get
assert score @s hs_max matches 22
succeed
