# @dummy
# @timeout 100

say [HeartStakesTest] player_isolation: start
dummy hs_test_peer spawn
say [HeartStakesTest] player_isolation: peer spawned
await delay 1t
attribute @s minecraft:max_health base set 20
say [HeartStakesTest] player_isolation: test player health set
attribute @a[name=hs_test_peer,limit=1] minecraft:max_health base set 20
say [HeartStakesTest] player_isolation: peer health set
await delay 1t
scoreboard players set @s hs_deaths 1
say [HeartStakesTest] player_isolation: death trigger set
await delay 1t
function heartstakes:on_death
say [HeartStakesTest] player_isolation: death function returned
await delay 1t
execute as @a[name=hs_test_peer,limit=1] store result score @s hs_max run attribute @s minecraft:max_health base get
say [HeartStakesTest] player_isolation: peer health read
assert score @s hs_max matches 19
say [HeartStakesTest] player_isolation: test player assertion passed
assert score @a[name=hs_test_peer,limit=1] hs_max matches 20
say [HeartStakesTest] player_isolation: peer assertion passed
dummy hs_test_peer leave
say [HeartStakesTest] player_isolation: peer removed
succeed
