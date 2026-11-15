# @dummy
# @timeout 100

say [HeartStakesTest] apple_reward: start
attribute @s minecraft:max_health base set 20
say [HeartStakesTest] apple_reward: base health set
await delay 1t
function heartstakes:on_eat_apple
say [HeartStakesTest] apple_reward: reward function returned
await delay 1t
say [HeartStakesTest] apple_reward: delayed after reward
execute store result score @s hs_max run attribute @s minecraft:max_health base get
say [HeartStakesTest] apple_reward: health read
assert score @s hs_max matches 22
say [HeartStakesTest] apple_reward: assertion passed
succeed
