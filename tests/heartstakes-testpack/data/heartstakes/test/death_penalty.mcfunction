# @dummy
# @timeout 100

say [HeartStakesTest] death_penalty: start
attribute @s minecraft:max_health base set 20
say [HeartStakesTest] death_penalty: base health set
await delay 1t
scoreboard players set @s hs_deaths 1
say [HeartStakesTest] death_penalty: death trigger set
await delay 1t
function heartstakes:on_death
say [HeartStakesTest] death_penalty: death function returned
await delay 1t
assert score @s hs_max matches 19
say [HeartStakesTest] death_penalty: health assertion passed
assert score @s hs_deaths matches 0
say [HeartStakesTest] death_penalty: death reset assertion passed
succeed
