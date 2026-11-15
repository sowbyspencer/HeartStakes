# @dummy
# @timeout 100

say [HeartStakesTest] minimum_health_floor: start
attribute @s minecraft:max_health base set 1
say [HeartStakesTest] minimum_health_floor: base health set
await delay 1t
scoreboard players set @s hs_deaths 1
say [HeartStakesTest] minimum_health_floor: death trigger set
await delay 1t
function heartstakes:on_death
say [HeartStakesTest] minimum_health_floor: death function returned
await delay 1t
assert score @s hs_max matches 1
say [HeartStakesTest] minimum_health_floor: health assertion passed
assert score @s hs_deaths matches 0
say [HeartStakesTest] minimum_health_floor: death reset assertion passed
succeed
