# @dummy
# @timeout 100

attribute @s minecraft:max_health base set 20
function heartstakes:on_eat_apple
execute store result score @s hs_test_max run attribute @s minecraft:max_health base get
assert score @s hs_test_max matches 22
succeed
