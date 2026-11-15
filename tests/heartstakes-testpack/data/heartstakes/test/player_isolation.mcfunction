# @dummy
# @timeout 100

dummy hs_test_peer spawn
attribute @s minecraft:max_health base set 20
attribute @a[name=hs_test_peer,limit=1] minecraft:max_health base set 20
scoreboard players set @s hs_deaths 1
await delay 2s
execute store result score @s hs_max run attribute @s minecraft:max_health base get
execute as @a[name=hs_test_peer,limit=1] store result score @s hs_max run attribute @s minecraft:max_health base get
assert score @s hs_max matches 19
assert score @a[name=hs_test_peer,limit=1] hs_max matches 20
dummy hs_test_peer leave
succeed
